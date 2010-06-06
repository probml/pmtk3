function [nodeLabels] = mrfEstMarginals(model, clamped)
% Compute node marginals, then compute max of each one
if nargin < 2, clamped = []; end
nodeBel = mrfInferMarginals(model, clamped);
[junk nodeLabels] = max(nodeBel,[],2); %#ok
end


