function p = binomialProb(X, mu, N)
% p(i) = p( X(i) | mu, N)

% This file is from pmtk3.googlecode.com

p = exp(binomialLogprob(struct('mu',mu,'N',N),X));
p = p(:);
end
