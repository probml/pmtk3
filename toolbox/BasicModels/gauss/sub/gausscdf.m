function p = gausscdf(X, mu, sigma)
% Univariate Gaussian cdf
% X(i,:) is i'th case

% This file is from pmtk3.googlecode.com

if nargin < 3, 
    mu = 0; 
    sigma = 1;
end
z = (X-mu) ./ sigma;
p = 0.5 * erfc(-z ./ sqrt(2));

if 0
% Alternative expression  from Bishop eq. 4.116
% (see corrections at
% https://research.microsoft.com/en-us/um/people/cmbishop/PRML/prml-errata-
% 2nd-pr-2009-09-09.pdf)
p2 = 0.5*erf(z/sqrt(2)) + 0.5;
assert(approxeq(p, p2))
end

end

