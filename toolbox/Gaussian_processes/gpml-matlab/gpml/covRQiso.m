function [A, B] = covRQiso(loghyper, x, z)

% Rational Quadratic covariance function with isotropic distance measure. The
% covariance function is parameterized as:
%
% k(x^p,x^q) = sf2 * [1 + (x^p - x^q)'*inv(P)*(x^p - x^q)/(2*alpha)]^(-alpha)
%
% where the P matrix is ell^2 times the unit matrix, sf2 is the signal
% variance and alpha is the shape parameter for the RQ covariance. The
% hyperparameters are:
%
% loghyper = [ log(ell)
%              log(sqrt(sf2))
%              log(alpha) ]
%
% For more help on design of covariance functions, try "help covFunctions".
%
% (C) Copyright 2006 by Carl Edward Rasmussen (2006-09-08)

if nargin == 0, A = '3'; return; end

[n, D] = size(x);

persistent K;
ell = exp(loghyper(1));
sf2 = exp(2*loghyper(2));
alpha = exp(loghyper(3));

if nargin == 2                                      % compute covariance matrix
  K = (1+0.5*sq_dist(x'/ell)/alpha);
  A = sf2*(K.^(-alpha));
elseif nargout == 2                              % compute test set covariances
  A = sf2*ones(size(z,1),1);
  B = sf2*((1+0.5*sq_dist(x'/ell,z'/ell)/alpha).^(-alpha));
else                                              % compute derivative matrices
  % check for correct dimension of the previously calculated kernel matrix
  if any(size(K)~=n)  
    K = (1+0.5*sq_dist(x'/ell)/alpha);
  end
  if z == 1                                           % length scale parameters
    A = sf2*K.^(-alpha-1).*sq_dist(x'/ell);
  elseif z == 2                                           % magnitude parameter
    A = 2*sf2*(K.^(-alpha));
  else
    A = sf2*K.^(-alpha).*(0.5*sq_dist(x'/ell)./K - alpha*log(K));
    clear K;
  end
end
