function [A, B] = covConst(logtheta, x, z);

% covariance function for a constant function. The covariance function is
% parameterized as:
%
% k(x^p,x^q) = 1/s2;
%
% The scalar hyperparameter is:
%
% logtheta = [ log(sqrt(s2)) ]
%
% For more help on design of covariance functions, try "help covFunctions".
%
% (C) Copyright 2006 by Carl Edward Rasmussen (2007-07-24)

if nargin == 0, A = '1'; return; end              % report number of parameters

is2 = exp(-2*logtheta);                                            % s2 inverse

if nargin == 2
  A = is2;
elseif nargout == 2                              % compute test set covariances
  A = is2;
  B = is2;
else                                                % compute derivative matrix
  A = -2*is2*ones(size(x,1));
end

