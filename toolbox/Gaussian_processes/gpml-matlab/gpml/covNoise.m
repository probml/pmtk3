function [A, B] = covNoise(logtheta, x, z);

% Independent covariance function, ie "white noise", with specified variance.
% The covariance function is specified as:
%
% k(x^p,x^q) = s2 * \delta(p,q)
%
% where s2 is the noise variance and \delta(p,q) is a Kronecker delta function
% which is 1 iff p=q and zero otherwise. The hyperparameter is
%
% logtheta = [ log(sqrt(s2)) ]
%
% For more help on design of covariance functions, try "help covFunctions".
%
% (C) Copyright 2006 by Carl Edward Rasmussen, 2006-03-24.

if nargin == 0, A = '1'; return; end              % report number of parameters

s2 = exp(2*logtheta);                                          % noise variance

if nargin == 2                                      % compute covariance matrix
  A = s2*eye(size(x,1));
elseif nargout == 2                              % compute test set covariances
  A = s2;
  B = 0;                               % zeros cross covariance by independence
else                                                % compute derivative matrix
  A = 2*s2*eye(size(x,1));
end
