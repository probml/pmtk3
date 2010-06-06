function [nodeBel, edgeBel, logZ] = crfInferMarginals(model, Xnode, Xedge)
% Compute node and edge marginals for conditional random field
% Xn is Ncases*NnodeFeatures*Nnodes
% Xe is Ncases*NedgeFeatures*Nedges

if isempty(model.infFun)
  fprintf('method %s does not support inference\n', model.methodName);
  return;
end

nodePot = UGM_makeCRFNodePotentials(Xnode, model.w, model.edgeStruct, model.infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge, model.v, model.edgeStruct, model.infoStruct);

[nodeBel, edgeBel,logZ]  = feval(model.infFun, nodePot, edgePot, ...
  model.edgeStruct, model.infArgs{:});
end
