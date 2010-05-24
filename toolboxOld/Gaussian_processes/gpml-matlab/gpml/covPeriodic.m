function [A, B] = covPeriodic(logtheta, x, z);

% covariance function for a smooth periodic function, with unit period. The 
% covariance function is:
%
% k(x^p, x^q) = sf2 * exp(-2*sin^2(pi*(x_p-x_q))/ell^2)
%
% where the hyperparameters are:
%
% logtheta = [ log(ell)
%              log(sqrt(sf2)) ]
%
% For more help on design of covariance functions, try "help covFunctions".
%
% (C) Copyright 2006 by Carl Edward Rasmussen (2006-04-07)

if nargin == 0, A = '2'; return; end

[n D] = size(x);
ell = exp(logtheta(1));
sf2 = exp(2*logtheta(2));

if nargin == 2
  A = sf2*exp(-2*(sin(pi*(repmat(x,1,n)-repmat(x',n,1)))/ell).^2);
elseif nargout == 2                              % compute test set covariances
  [nn D] = size(z);
  A = sf2*ones(nn,1);
  B = sf2*exp(-2*(sin(pi*(repmat(x,1,nn)-repmat(z',n,1)))/ell).^2);
else                                              % compute derivative matrices
  if z == 1
    r = (sin(pi*(repmat(x,1,n)-repmat(x',n,1)))/ell).^2;
    A = 4*sf2*exp(-2*r).*r;
  else
    A = 2*sf2*exp(-2*(sin(pi*(repmat(x,1,n)-repmat(x',n,1)))/ell).^2);
  end
end
