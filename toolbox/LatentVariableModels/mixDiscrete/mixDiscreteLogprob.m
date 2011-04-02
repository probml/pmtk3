function logp = mixDiscreteLogprob(model, X)
%% Calculate logp(i) = log p(X(i,:) | model)
% Can handle NaNs
%%

% This file is from pmtk3.googlecode.com

[pZ, logp] = mixDiscreteInferLatent(model, X); 
end
