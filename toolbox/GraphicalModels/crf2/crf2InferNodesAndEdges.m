function [nodeBel, edgeBel, logZ] = crf2InferNodesAndEdges(model, Xnode, Xedge)
% Compute node and edge marginals for conditional random field
% [nodeBel, edgeBel, logZ] = crf2InferNodesAndEdges(model, Xn, Xe)
% Input can be 
% Xn is NnodeFeatures*Nnodes
% Xe is NedgeFeatures*Nedges
% or
% Xn is Ncases*NnodeFeatures*Nnodes
% Xe is Ncases*NedgeFeatures*Nedges
%
% nodeBel is Nnodes*Nstates*Ncases
% edgeBel is Nstates*Nstates*Nedges*Ncases

% This file is from pmtk3.googlecode.com

if isempty(model.infFun)
  fprintf('method %s does not support inference\n', model.methodName);
  return;
end

if ndims(Xnode)==2
  Xnode = reshape(Xnode, [1 size(Xnode)]);
  Xedge = reshape(Xedge, [1 size(Xedge)]);
end
[Ncases, NnodeFeatures, Nnodes] = size(Xnode); %#ok
K  = max(model.nStates);
nodeBel = zeros(Nnodes, K, Ncases);
edgeBel = zeros(K, K, model.nEdges, Ncases);
logZ = zeros(1, Ncases);

infoStruct = UGM_makeCRFInfoStruct(Xnode, Xedge, ...
    model.edgeStruct, model.ising, model.tied);
nodePot = UGM_makeCRFNodePotentials(Xnode, model.w, model.edgeStruct, infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge, model.v, model.edgeStruct, infoStruct);
for i=1:Ncases
  [nodeBel(:,:,i), edgeBel(:,:,:,i), logZ(i)]  = ...
    feval(model.infFun, nodePot(:,:,i), edgePot(:,:,:,i), ...
    model.edgeStruct, model.infArgs{:});
end
end
