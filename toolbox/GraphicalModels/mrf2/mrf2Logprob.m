function [logZ] = mrf2Logprob(model, y)
% logZ(i) = log p(y(i,:))
% We run inference with the y nodes clamped 


% This file is from pmtk3.googlecode.com

edgeStruct = model.edgeStruct;
[Ncases Nnodes] = size(y);
nEdges = size(edgeStruct.edgeEnds,1); Nedges = nEdges;
nInstances = Ncases; nNodes = Nnodes; 
Xnode = [ones(nInstances,1,nNodes)];
Xedge = [ones(nInstances,1,nEdges)];


infoStruct = UGM_makeCRFInfoStruct(Xnode, Xedge, edgeStruct, model.ising, model.tied);
nodePot = UGM_makeCRFNodePotentials(Xnode, model.nodeWeights, edgeStruct, infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge, model.edgeWeights, edgeStruct, infoStruct);


logZ = zeros(1, Ncases);


% create initial jtree structure using potentials from case 1
% Since this is an mrf, potentials are the same for all cases
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
if mrf.jtree.treewidth > 5
  warning(sprintf('mrf2logprob: treewidth = %d, Ncases=%d\n', ...
    mrf.jtree.treewidth, Ncases));
end

for i = 1:Ncases
  [nodeBelCell, logZ(i)] = mrfInferNodes(mrf, 'clamped', y(i,:)); %#ok
end
[~, logZ0] = mrfInferNodes(mrf)
logZ = logZ - logZ0;


end
