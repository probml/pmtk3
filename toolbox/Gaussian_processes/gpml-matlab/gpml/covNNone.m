function [A, B] = covNNone(loghyper, x, z)

% Neural network covariance function with a single parameter for the distance
% measure. The covariance function is parameterized as:
%
% k(x^p,x^q) = sf2 * asin(x^p'*P*x^q / sqrt[(1+x^p'*P*x^p)*(1+x^q'*P*x^q)])
%
% where the x^p and x^q vectors on the right hand side have an added extra bias
% entry with unit value. P is ell^-2 times the unit matrix and sf2 controls the
% signal variance. The hyperparameters are:
%
% loghyper = [ log(ell)
%              log(sqrt(sf2) ]
%
% For more help on design of covariance functions, try "help covFunctions".
%
% (C) Copyright 2006 by Carl Edward Rasmussen (2006-03-24)

if nargin == 0, A = '2'; return; end              % report number of parameters

persistent Q K;                 
[n D] = size(x);
ell = exp(loghyper(1)); em2 = ell^(-2);
sf2 = exp(2*loghyper(2));
x = x/ell;

if nargin == 2                                             % compute covariance
  Q = x*x';
  K = (em2+Q)./(sqrt(1+em2+diag(Q))*sqrt(1+em2+diag(Q)'));
  A = sf2*asin(K);                 
elseif nargout == 2                              % compute test set covariances
  z = z/ell; 
  A = sf2*asin((em2+sum(z.*z,2))./(1+em2+sum(z.*z,2)));
  B = sf2*asin((em2+x*z')./sqrt((1+em2+sum(x.*x,2))*(1+em2+sum(z.*z,2)')));
else                                                % compute derivative matrix
  % check for correct dimension of the previously calculated kernel matrix
  if any(size(Q)~=n)  
    Q = x*x';
  end
  % check for correct dimension of the previously calculated kernel matrix
  if any(size(K)~=n)  
    K = (em2+Q)./(sqrt(1+em2+diag(Q))*sqrt(1+em2+diag(Q)'));
  end
  if z == 1                                                   % first parameter
    v = (em2+sum(x.*x,2))./(1+em2+diag(Q));
    A = -2*sf2*((em2+Q)./(sqrt(1+em2+diag(Q))*sqrt(1+em2+diag(Q)'))- ...
                            K.*(repmat(v,1,n)+repmat(v',n,1))/2)./sqrt(1-K.^2);
    clear Q;
  else                                                       % second parameter
    A = 2*sf2*asin(K);
    clear K;
  end
end
