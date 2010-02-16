function [logp, logPz] = mixGaussLogprob(model, X)
% logp(i) = log p(X(i,:) | model)
% logPz(i,k) = log p(z=k, X(i,:), model) unnormalized
K = model.K;
N = size(X,1);
logPz = zeros(N, K);
for k=1:K
  modelK.mu = model.mu(:, k); modelK.Sigma = model.Sigma(:, :, k);
  logPz(:, k) = log(model.mixweight(k)+eps) + ...
    gaussLogprob(modelK, X);
end
logp = logsumexp(logPz, 2);
