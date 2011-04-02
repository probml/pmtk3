function [pZ, ll] = mixGaussInferLatent(model, X)
% Infer latent mixture node from a set of data
% pZ(i, k) = p( Z = k | X(i, :), model) 
% ll(i) = log p(X(i, :) | model)  
% X must be fully observed (no NaNs)

% This file is from pmtk3.googlecode.com

nmix   = model.nmix; 
[n, d] = size(X); 
logMix = log(rowvec(model.mixWeight)); 
logPz  = zeros(n, nmix); 

mu    = model.cpd.mu;
Sigma = model.cpd.Sigma;
for k = 1:nmix
  logPz(:, k) = logMix(k) + gaussLogprob(mu(:, k), Sigma(:, :, k), X);
end

  
[logPz, ll] = normalizeLogspace(logPz);
pZ          = exp(logPz);
end
