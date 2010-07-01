function [nodeLabels] = mrf2MapMarginals(model, clamped)
% Compute node marginals, then compute max of each one
%PMTKlatentModel mrf2
if nargin < 2, clamped = []; end
nodeBel = mrf2InferMarginals(model, clamped);
[junk nodeLabels] = max(nodeBel,[],2); %#ok
end


