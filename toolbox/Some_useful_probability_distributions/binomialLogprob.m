function logp = binomialLogprob(model, X)
% logp(i) = log p( X(i) | model.mu, model.N)
mu = model.mu;
N  = model.N;
n = size(X, 1);
X = X(:);
if isscalar(mu)
    M = repmat(mu, n, 1);
    N = repmat(N, n, 1);
else
    M = mu(:);
    N = repmat(N(1), n, 1);
end
logp = nchoosekln(N, X) + X.*log(M) + (N - X).*log1p(-M);



%logp2 = log(binopdf(X, N, M));
%assert(approxeq(logp, logp2)); 



end