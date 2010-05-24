function [A, B] = covSum(covfunc, logtheta, x, z);

% covSum - compose a covariance function as the sum of other covariance
% functions. This function doesn't actually compute very much on its own, it
% merely does some bookkeeping, and calls other covariance functions to do the
% actual work.
%
% For more help on design of covariance functions, try "help covFunctions".
%
% (C) Copyright 2006 by Carl Edward Rasmussen, 2006-03-20.

for i = 1:length(covfunc)                   % iterate over covariance functions
  f = covfunc(i);
  if iscell(f{:}), f = f{:}; end          % dereference cell array if necessary
  j(i) = cellstr(feval(f{:}));
end

if nargin == 1,                                   % report number of parameters
  A = char(j(1)); for i=2:length(covfunc), A = [A, '+', char(j(i))]; end
  return
end

[n, D] = size(x);

v = [];              % v vector indicates to which covariance parameters belong
for i = 1:length(covfunc), v = [v repmat(i, 1, eval(char(j(i))))]; end

switch nargin
case 3                                              % compute covariance matrix
  A = zeros(n, n);                       % allocate space for covariance matrix
  for i = 1:length(covfunc)                  % iteration over summand functions
    f = covfunc(i);
    if iscell(f{:}), f = f{:}; end        % dereference cell array if necessary
    A = A + feval(f{:}, logtheta(v==i), x);            % accumulate covariances
  end

case 4                      % compute derivative matrix or test set covariances
  if nargout == 2                                % compute test set cavariances
    A = zeros(size(z,1),1); B = zeros(size(x,1),size(z,1));    % allocate space
    for i = 1:length(covfunc)
      f = covfunc(i);
      if iscell(f{:}), f = f{:}; end      % dereference cell array if necessary
      [AA BB] = feval(f{:}, logtheta(v==i), x, z);   % compute test covariances
      A = A + AA; B = B + BB;                                  % and accumulate
    end
  else                                            % compute derivative matrices
    i = v(z);                                       % which covariance function
    j = sum(v(1:z)==i);                    % which parameter in that covariance
    f = covfunc(i);
    if iscell(f{:}), f = f{:}; end        % dereference cell array if necessary
    A = feval(f{:}, logtheta(v==i), x, j);                 % compute derivative
  end

end

