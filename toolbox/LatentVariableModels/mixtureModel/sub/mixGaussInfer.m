function [z, pz, ll] = mixGaussInfer(model, X)
% z(i) = argmax_k p(z=k|X(i,:), model) hard clustering
% pz(i,k) = p(z=k|X(i,:), model) soft responsibility
% ll(i) = log p(X(i,:) | model)  logprob of observed data
% This can handle NaNs in X

% This file is from pmtk3.googlecode.com

K = numel(model.mixweight);
N = size(X,1);
logPz = zeros(N, K);
logmix = log(model.mixweight+eps);
for k=1:K
  modelK.mu = model.mu(:, k); modelK.Sigma = model.Sigma(:, :, k);
  logPz(:, k) = logmix(k) +  gaussLogprob(modelK, X);
end
z = maxidx(logPz, [], 2);
if nargout > 1
  [logPz, ll] = normalizeLogspace(logPz);
  pz = exp(logPz);
end
end
