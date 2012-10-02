function logp = mixModelLogprob(model, X)
%% Calculate logp(i) = log p(X(i,:) | model)
%
%%

% This file is from pmtk3.googlecode.com

[pZ, logp] = mixModelInferLatent(model, X); 
end