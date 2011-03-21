function [logZ, nodeBel, edgeBel, mrf] = crf2InferNodes(model, Xnode, Xedge, varargin)
% Compute node and edge marginals, and log partition function
%
% XNode: Ncases * NnodeFeatures * Nnodes
% Xedge: Ncases * NedgeFeatures * Nedges
%   where Nedges = Nnodes * (Nnodes-1) / 2
% if Xedge = [], it is automatically created
% We add a column of 1s to Xnode and Edge internally.


% This file is from pmtk3.googlecode.com

mrf = [];
[infMethod] = process_options(varargin, 'infMethod', 'bruteforce');


edgeStruct = model.edgeStruct;

if isempty(Xedge)
  Xedge = UGM_makeEdgeFeatures(Xnode, edgeStruct.edgeEnds);
  %Xedge = zeros(nCases, 0, nEdges);
end

[Ncases NnodeFeatures Nnodes] = size(Xnode); %#ok
[Ncases2 NedgeFeatures Nedges] = size(Xedge); %#ok

nInstances = Ncases; nNodes = Nnodes; nEdges = Nedges;
Xnode = [ones(nInstances,1,nNodes) Xnode];
Xedge = [ones(nInstances,1,nEdges) Xedge];


infoStruct = UGM_makeCRFInfoStruct(Xnode, Xedge, edgeStruct, model.ising, model.tied);
nodePot = UGM_makeCRFNodePotentials(Xnode, model.nodeWeights, edgeStruct, infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge, model.edgeWeights, edgeStruct, infoStruct);


Nstates = model.nStates(1);
logZ = zeros(1, Ncases);
if nargout >= 2
  nodeBel = zeros(Nnodes, Nstates, Ncases);
else
  nodeBel = [];
end
if nargout >= 3
  edgeBel = zeros(Nstates, Nstates, Nedges, Ncases); % big!
else
  edgeBel = [];
end


if strcmp(infMethod, 'jtree')
  % create initial jtree structure using potentials from case 1
  i = 1;
  nodePots = cell(1, Nnodes);
  edgePots = cell(1, Nedges);
  for n=1:Nnodes
    nodePots{n} = tabularFactorCreate(nodePot(n,:,i), n);
  end
  for e=1:Nedges
    n1 = edgeStruct.edgeEnds(e,1);
    n2 = edgeStruct.edgeEnds(e,2);
    edgePots{e} = tabularFactorCreate(edgePot(:,:,e,i), [n1 n2]);
  end
  mrf = mrfCreate(model.G, 'nodePots', nodePots, 'edgePots', edgePots);
  fprintf('crf treewidth = %d\n', mrf.jtree.treewidth);
end

for i = 1:Ncases
  switch infMethod
    case 'bruteforce',
        [nodeBel_i, edgeBel_i,logZ_i] = UGM_Infer_Exact(nodePot(:,:,i), edgePot(:,:,:,i), edgeStruct);
    case 'loopy'
      [nodeBel_i, edgeBel_i, logZ_i] = UGM_Infer_LBP(nodePot(:,:,i), edgePot(:,:,:,i), edgeStruct);
      
    case 'jtree'
      % create potentials for this case
      for n=1:Nnodes
        nodePots{n} = tabularFactorCreate(nodePot(n,:,i), n);
      end
      for e=1:Nedges
        n1 = edgeStruct.edgeEnds(e,1);
        n2 = edgeStruct.edgeEnds(e,2);
        edgePots{e} = tabularFactorCreate(edgePot(:,:,e,i), [n1 n2]);
      end
      factors = [nodePots, edgePots];
      mrf.jtree = updateJtreePots(mrf.jtree, factors);
      %mrf = mrfCreate(model.G, 'nodePots', nodePots, 'edgePots', edgePots);
      [nodeBelCell, logZ_i, edgeBelCell] = mrfInferNodes(mrf);
      % Convert from cell array
      nodeBel_i = zeros(Nnodes, Nstates);
      for n=1:Nnodes
        nodeBel_i(n, :) = nodeBelCell{n}.T(:)';
      end
      edgeBel_i = zeros(Nstates, Nstates, Nedges);
      for e=1:Nedges
        edgeBel_i(:, :, e) = edgeBelCell{e}.T;
      end
  
    otherwise
      error(['unrecognized infmethod ' infMethod])
  end
  logZ(i) = logZ_i;
  if ~isempty(nodeBel), nodeBel(:,:,i) = nodeBel_i; end
   if ~isempty(edgeBel), edgeBel(:,:,:,i) = edgeBel_i; end  
end


end
