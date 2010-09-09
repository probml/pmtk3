function [mu f g H] = maxFuncNumerical(fn, start, options)
% Maximize a function using numerical gradients and Hessians
% fn(X(i,:)) returns the score function for that *row* vector

% This file is from pmtk3.googlecode.com


if nargin < 3, options = []; end
options.Method = 'cg';
options.Display = 'none';
mu =  minFunc(@foo,start(:),options);
if nargout > 1
  [f g H] = foo(mu(:)); % evaluate fn and derivs at optimum
  f = -f; g = -g; H = -H;
end

  function [f,g,H] = foo(theta)
    % minFunc will always call foo with a single column vector
    % but fn and gradest expect row vectors
    f = -fn(theta');
    g = -gradest(fn, theta')'; % gradest returns row vector, minfunc wants column
    H = -hessian(fn, theta');
  end

end
