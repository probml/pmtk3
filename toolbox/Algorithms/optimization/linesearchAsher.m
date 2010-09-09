function [xn,alpha] = linesearchSimple(f, x, p, fx, gx, sigma, alphamin)
%
% Uri Ascher
%
% line search: given current iterate x and direction p,
% find alpha in [alphamin,1] such that xn = x + alpha*p
% gives sufficient descent in f, as specified by sigma.
% Upon return, if alpha <= alphamin then failure

% This file is from pmtk3.googlecode.com


if nargin < 6, sigma = 1e-3; end
if nargin < 7, alphamin = 1e-1; end

pgx = p' * gx;
alpha = 1;
xn = x + alpha * p;
fxn = feval(f,xn);
while (fxn > fx + sigma * alpha * pgx) & (alpha > alphamin)
  mu = -0.5 * pgx * alpha / (fxn - fx - alpha * pgx );
  if mu < .1
    mu = .5; % don't trust quadratic interpolation from far away
  end
  alpha = mu * alpha;
  xn = x + alpha * p;
  fxn = feval(f,xn);
end

end
