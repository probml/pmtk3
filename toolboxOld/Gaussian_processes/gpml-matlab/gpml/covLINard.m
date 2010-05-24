function [A, B] = covLINard(logtheta, x, z);

% Linear covariance function with Automatic Relevance Determination (ARD). The
% covariance function is parameterized as:
%
% k(x^p,x^q) = x^p'*inv(P)*x^q
%
% where the P matrix is diagonal with ARD parameters ell_1^2,...,ell_D^2, where
% D is the dimension of the input space. The hyperparameters are:
%
% logtheta = [ log(ell_1)
%              log(ell_2)
%               .
%              log(ell_D) ]
%
% Note that there is no bias term; use covConst to add a bias.
%
% For more help on design of covariance functions, try "help covFunctions".
%
% (C) Copyright 2006 by Carl Edward Rasmussen (2006-03-24)

if nargin == 0, A = 'D'; return; end              % report number of parameters

ell = exp(logtheta);
x = x*diag(1./ell);

if nargin == 2
  A = x*x';
elseif nargout == 2                              % compute test set covariances
  z = z*diag(1./ell);
  A = sum(z.*z,2);
  B = x*z';
else                                              % compute derivative matrices
  A = -2*x(:,z)*x(:,z)';
end
