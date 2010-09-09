function [nodeBel, edgeBel, logZ] = mrf2InferNodesAndEdges(model, clamped)
% Compute node and edge marginals, and log partition function
% clamped is an optional 1*D vector, where
% clamped(i) = 0 means node i is not observed
% and clamped(i) = k means node is clamped to state k

% This file is from pmtk3.googlecode.com

if nargin < 2, clamped = []; end

if isempty(model.infFun)
  fprintf('method %s does not support inference\n', model.methodName);
  return;
end

if isempty(clamped)
  [nodeBel, edgeBel,logZ]  = feval(model.infFun, model.nodePot, model.edgePot, ...
    model.edgeStruct, model.infArgs{:});
else
  [nodeBel, edgeBel, logZ] = UGM_Infer_Conditional(model.nodePot, model.edgePot, ...
    model.edgeStruct, clamped(:), model.infFun, model.infArgs{:});
end
end
