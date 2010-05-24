function p = binomprob(X, mu, N)
% p(i) = p( X(i) | mu, N)
p = exp(binomialLogprob(struct('mu',mu,'N',N),X));
p = p(:);
end
