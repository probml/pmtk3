function y = gauss(mu, covar, x)
%GAUSS	Evaluate a Gaussian distribution.
%
%	Description
%
%	Y = GAUSS(MU, COVAR, X) evaluates a multi-variate Gaussian  density
%	in D-dimensions at a set of points given by the rows of the matrix X.
%	The Gaussian density has mean vector MU and covariance matrix COVAR.
%
%	See also
%	GSAMP, DEMGAUSS
%

%	Copyright (c) Ian T Nabney (1996-2001)

[n, d] = size(x);

[j, k] = size(covar);

% Check that the covariance matrix is the correct dimension
if ((j ~= d) | (k ~=d))
  error('Dimension of the covariance matrix and data should match');
end
   
invcov = inv(covar);
mu = reshape(mu, 1, d);    % Ensure that mu is a row vector

x = x - ones(n, 1)*mu;
fact = sum(((x*invcov).*x), 2);

y = exp(-0.5*fact);

y = y./sqrt((2*pi)^d*det(covar));
