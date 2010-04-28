function [A, B] = covProd(covfunc, logtheta, x, z);

% covProd - compose a covariance function as the product of other covariance
% functions. This function doesn't actually compute very much on its own, it
% merely does some bookkeeping, and calls other covariance functions to do the
% actual work.
%
% For more help on design of covariance functions, try "help covFunctions".
%
% (C) Copyright 2006 by Carl Edward Rasmussen, 2006-04-06.

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
  A = ones(n, n);                       % allocate space for covariance matrix
  for i = 1:length(covfunc)                   % iteration over factor functions
    f = covfunc(i);
    if iscell(f{:}), f = f{:}; end        % dereference cell array if necessary
    A = A .* feval(f{:}, logtheta(v==i), x);             % multiply covariances
  end

case 4                      % compute derivative matrix or test set covariances
  if nargout == 2                                % compute test set cavariances
    A = ones(size(z,1),1); B = ones(size(x,1),size(z,1));      % allocate space
    for i = 1:length(covfunc)
      f = covfunc(i);
      if iscell(f{:}), f = f{:}; end      % dereference cell array if necessary
      [AA BB] = feval(f{:}, logtheta(v==i), x, z);   % compute test covariances
      A = A .* AA; B = B .* BB;                                % and accumulate
    end
  else                                            % compute derivative matrices
    A = ones(n, n);
    ii = v(z);                                      % which covariance function
    j = sum(v(1:z)==ii);                   % which parameter in that covariance
    for i = 1:length(covfunc)
      f = covfunc(i);
      if iscell(f{:}), f = f{:}; end      % dereference cell array if necessary
      if i == ii
        A = A .* feval(f{:}, logtheta(v==i), x, j);       % multiply derivative
      else
        A = A .* feval(f{:}, logtheta(v==i), x);          % multiply covariance
      end
    end
  end

end
