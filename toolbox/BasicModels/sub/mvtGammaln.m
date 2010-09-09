function logp = mvtGammaln(n, alpha)
% returns the log of multivariate gamma(n, alpha) value.
% necessary for avoiding underflow/overflow problems
% alpha > (n-1)/2
% See Muirhead pp 61-62.

% This file is from pmtk3.googlecode.com

logp = ((n*(n-1))/4)*log(pi)+sum(gammaln(alpha+0.5*(1-[1:n])));

end
