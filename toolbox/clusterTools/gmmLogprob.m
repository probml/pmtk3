function [logp] = mixGauss(model, X)
% logp(i) = log p(X(i,:) | model)

K = model.K;
N = size(X,1);
logPost = zeros(N, K);
for k=1:K
  modelK.mu = model.mu(:, k); modelK.Sigma = model.sigma(:, :, k);
  logPost(:, k) = log(model.mixweights(k)+eps) + ...
    gaussLogprob(model, X);
end
logp = logsumexp(logPost, 2);

  
