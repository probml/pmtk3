function [x, options, flog, pointlog] = conjgrad(f, x, options, gradf, ...
                                    varargin)
%CONJGRAD Conjugate gradients optimization.
%
%	Description
%	[X, OPTIONS, FLOG, POINTLOG] = CONJGRAD(F, X, OPTIONS, GRADF) uses a
%	conjugate gradients algorithm to find the minimum of the function
%	F(X) whose gradient is given by GRADF(X).  Here X is a row vector and
%	F returns a scalar value.  The point at which F has a local minimum
%	is returned as X.  The function value at that point is returned in
%	OPTIONS(8).  A log of the function values after each cycle is
%	(optionally) returned in FLOG, and a log of the points visited is
%	(optionally) returned in POINTLOG.
%
%	CONJGRAD(F, X, OPTIONS, GRADF, P1, P2, ...) allows  additional
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
%	OPTIONS(9) is set to 1 to check the user defined gradient function.
%
%	OPTIONS(10) returns the total number of function evaluations
%	(including those in any line searches).
%
%	OPTIONS(11) returns the total number of gradient evaluations.
%
%	OPTIONS(14) is the maximum number of iterations; default 100.
%
%	OPTIONS(15) is the precision in parameter space of the line search;
%	default 1E-4.
%
%	See also
%	GRADDESC, LINEMIN, MINBRACK, QUASINEW, SCG
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
% Need a precise line search for success
if options(15) > 0
  line_options(2) = options(15);
else
  line_options(2) = 1e-4;
end

display = options(1);

% Next two lines allow conjgrad to work with expression strings
f = fcnchk(f, length(varargin));
gradf = fcnchk(gradf, length(varargin));

%  Check gradients
if (options(9))
  feval('gradchek', x, f, gradf, varargin{:});
end

options(10) = 0;
options(11) = 0;
nparams = length(x);
fnew = feval(f, x, varargin{:});
options(10) = options(10) + 1;
gradnew = feval(gradf, x, varargin{:});
options(11) = options(11) + 1;
d = -gradnew;		% Initial search direction
br_min = 0;
br_max = 1.0;	% Initial value for maximum distance to search along
tol = sqrt(eps);

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

  gg = gradold*gradold';
  if (gg == 0.0)
    % If the gradient is zero then we are done.
    options(8) = fnew;
    return;
  end

  % This shouldn't occur, but rest of code depends on d being downhill
  if (gradnew*d' > 0)
    d = -d;
    if options(1) >= 0
      warning('search direction uphill in conjgrad');
    end
  end

  line_sd = d./norm(d);
  [lmin, line_options] = feval('linemin', f, xold, line_sd, fold, ...
    line_options, varargin{:});
  options(10) = options(10) + line_options(10);
  options(11) = options(11) + line_options(11);
  % Set x and fnew to be the actual search point we have found
  x = xold + lmin * line_sd;
  fnew = line_options(8);

  % Check for termination
  if (max(abs(x - xold)) < options(2) & max(abs(fnew - fold)) < options(3))
    options(8) = fnew;
    return;
  end

  gradnew = feval(gradf, x, varargin{:});
  options(11) = options(11) + 1;

  % Use Polak-Ribiere formula to update search direction
  gamma = ((gradnew - gradold)*(gradnew)')/gg;
  d = (d .* gamma) - gradnew;

  if (display > 0)
    fprintf(1, 'Cycle %4d  Function %11.6f\n', j, line_options(8));
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
