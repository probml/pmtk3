function [A, B] = covMatern5iso(loghyper, x, z)

% Matern covariance function with nu = 5/2 and isotropic distance measure. The
% covariance function is:
%
% k(x^p,x^q) = s2f * (1 + sqrt(5)*d + 5*d/3) * exp(-sqrt(5)*d)
%
% where d is the distance sqrt((x^p-x^q)'*inv(P)*(x^p-x^q)), P is ell times
% the unit matrix and sf2 is the signal variance. The hyperparameters are:
%
% loghyper = [ log(ell)
%              log(sqrt(sf2)) ]
%
% For more help on design of covariance functions, try "help covFunctions".
%
% (C) Copyright 2006 by Carl Edward Rasmussen (2006-03-24)

if nargin == 0, A = '2'; return; end

persistent K;
[n, D] = size(x);
ell = exp(loghyper(1));
sf2 = exp(2*loghyper(2));

x = sqrt(5)*x/ell;

if nargin == 2                                      % compute covariance matrix
  A = sq_dist(x');
  K = sf2*exp(-sqrt(A)).*(1+sqrt(A)+A/3);
  A = K;
elseif nargout == 2                              % compute test set covariances
  z = sqrt(5)*z/ell;
  A = sf2;
  B = sq_dist(x',z');
  B = sf2*exp(-sqrt(B)).*(1+sqrt(B)+B/3);
else                                              % compute derivative matrices
  if z == 1
    A = sq_dist(x');
    A = sf2*(A+sqrt(A).^3).*exp(-sqrt(A))/3;
  else
    % check for correct dimension of the previously calculated kernel matrix
    if any(size(K)~=n)  
      K = sq_dist(x');
      K = sf2*exp(-sqrt(K)).*(1+sqrt(K)+K/3);
    end
    A = 2*K;
    clear K;
  end
end
