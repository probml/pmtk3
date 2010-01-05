function [x, options, flog, pointlog] = quasinew(f, x, options, gradf, ...
                                    varargin)
%QUASINEW Quasi-Newton optimization.
%
%	Description
%	[X, OPTIONS, FLOG, POINTLOG] = QUASINEW(F, X, OPTIONS, GRADF)  uses a
%	quasi-Newton algorithm to find a local minimum of the function F(X)
%	whose gradient is given by GRADF(X).  Here X is a row vector and F
%	returns a scalar value.   The point at which F has a local minimum is
%	returned as X.  The function value at that point is returned in
%	OPTIONS(8). A log of the function values after each cycle is
%	(optionally) returned in FLOG, and a log of the points visited is
%	(optionally) returned in POINTLOG.
%
%	QUASINEW(F, X, OPTIONS, GRADF, P1, P2, ...) allows  additional
%	arguments to be passed to F() and GRADF().
%
%	The optional parameters have the following interpretations.
%
%	OPTIONS(1) is set to 1 to display error values; also logs error
%	values in the return argument ERRLOG, and the points visited in the
%	return argument POINTSLOG.  If OPTIONS(1) is set to 0, then only
%	warning messages are displayed.  If OPTIONS(1) is -1, then nothing is
%	displayed.
%
%	OPTIONS(2) is a measure of the absolute precision required for the
%	value of X at the solution.  If the absolute difference between the
%	values of X between two successive steps is less than OPTIONS(2),
%	then this condition is satisfied.
%
%	OPTIONS(3) is a measure of the precision required of the objective
%	function at the solution.  If the absolute difference between the
%	objective function values between two successive steps is less than
%	OPTIONS(3), then this condition is satisfied. Both this and the
%	previous condition must be satisfied for termination.
%
%	OPTIONS(9) should be set to 1 to check the user defined gradient
%	function.
%
%	OPTIONS(10) returns the total number of function evaluations
%	(including those in any line searches).
%
%	OPTIONS(11) returns the total number of gradient evaluations.
%
%	OPTIONS(14) is the maximum number of iterations; default 100.
%
%	OPTIONS(15) is the precision in parameter space of the line search;
%	default 1E-2.
%
%	See also
%	CONJGRAD, GRADDESC, LINEMIN, MINBRACK, SCG
%

%	Copyright (c) Ian T Nabney (1996-2001)

%  Set up the options.
if length(options) < 18
  error('Options vector too short')
end

if(options(14))
  niters = options(14);
else
  niters = 100;
end

% Set up options for line search
line_options = foptions;
% Don't need a very precise line search
if options(15) > 0
  line_options(2) = options(15);
else
  line_options(2) = 1e-2;  % Default
end
% Minimal fractional change in f from Newton step: otherwise do a line search
min_frac_change = 1e-4;	

display = options(1);

% Next two lines allow quasinew to work with expression strings
f = fcnchk(f, length(varargin));
gradf = fcnchk(gradf, length(varargin));

% Check gradients
if (options(9))
  feval('gradchek', x, f, gradf, varargin{:});
end

nparams = length(x);
fnew = feval(f, x, varargin{:});
options(10) = options(10) + 1;
gradnew = feval(gradf, x, varargin{:});
options(11) = options(11) + 1;
p = -gradnew;		% Search direction
hessinv = eye(nparams); % Initialise inverse Hessian to be identity matrix
j = 1;
if nargout >= 3
  flog(j, :) = fnew;
  if nargout == 4
    pointlog(j, :) = x;
  end
end

while (j <= niters)

  xold = x;
  fold = fnew;
  gradold = gradnew;

  x = xold + p;
  fnew = feval(f, x, varargin{:});
  options(10) = options(10) + 1;

  % This shouldn't occur, but rest of code depends on sd being downhill
  if (gradnew*p' >= 0)
    p = -p;
    if options(1) >= 0
      warning('search direction uphill in quasinew');
    end
  end

  % Does the Newton step reduce the function value sufficiently?
  if (fnew >= fold + min_frac_change * (gradnew*p'))
    % No it doesn't
    % Minimize along current search direction: must be less than Newton step
    [lmin, line_options] = feval('linemin', f, xold, p, fold, ...
      line_options, varargin{:});
    options(10) = options(10) + line_options(10);
    options(11) = options(11) + line_options(11);
    % Correct x and fnew to be the actual search point we have found
    x = xold + lmin * p;
    p = x - xold;
    fnew = line_options(8);
  end

  % Check for termination
  if (max(abs(x - xold)) < options(2) & max(abs(fnew - fold)) < options(3))
    options(8) = fnew;
    return;
  end
  gradnew = feval(gradf, x, varargin{:});
  options(11) = options(11) + 1;
  v = gradnew - gradold;
  vdotp = v*p';

  % Skip update to inverse Hessian if fac not sufficiently positive
  if (vdotp*vdotp > eps*sum(v.^2)*sum(p.^2)) 
    Gv = (hessinv*v')';
    vGv = sum(v.*Gv);
    u = p./vdotp - Gv./vGv;
    % Use BFGS update rule
    hessinv = hessinv + (p'*p)/vdotp - (Gv'*Gv)/vGv + vGv*(u'*u);
  end

  p = -(hessinv * gradnew')';

  if (display > 0)
    fprintf(1, 'Cycle %4d  Function %11.6f\n', j, fnew);
  end

  j = j + 1;
  if nargout >= 3
    flog(j, :) = fnew;
    if nargout == 4
      pointlog(j, :) = x;
    end
  end
end

% If we get here, then we haven't terminated in the given number of 
% iterations.

options(8) = fold;
if (options(1) >= 0)
  disp(maxitmess);
end
