function [logp] = gmmLogprob(model, X)
% logp(i) = log p(X(i,:) | model)

K = model.K;
N = size(X,1);
logPost = zeros(N, K);
for k=1:K
  logPost(:, k) = log(model.mixweights(k)+eps) + ...
    gaussLogprob(X, model.mu(:,k), model.Sigma(:,:,k));
end
logp = logsumexp(logPost, 2);

  
