function [X, mu, sigma2] = polyBasis(x, d, mu, sigma2)
%% Polynomial basis expansion of degree d
% function [X] = polyBasis(x, d)
% x(i) -> [1 x(i) x(i)^2 ... x(i)^d] stored in rows of X
% We put highest powers first, to be consistent with Matlab's convention (see polyfit)
%
% function [X, mu, sigma2] = polyBasis(x, d)
% We standardize x first, and return the mean and variance
%
% function [X] = polyBasis(x, d, mu, sigma2)
% We standardize x first using specified  mean and variance

% This file is from pmtk3.googlecode.com


x = x(:);
if nargout > 1
  [x, mu,  sigma2] = standardize(x);
elseif nargin > 2
  [x] = standardize(x, mu, sigma2);
end
n = size(x,1);
X(:,1) = ones(n,1,class(x));
for j = 2:d+1
   X(:,j) = x.*X(:,j-1);
end

if 0
X(:,d+1) = ones(n,1,class(x));
for j = d:-1:1
   X(:,j) = x.*X(:,j+1);
end
end

end
