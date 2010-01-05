function [x, options, flog, pointlog] = graddesc(f, x, options, gradf, ...
			varargin)
%GRADDESC Gradient descent optimization.
%
%	Description
%	[X, OPTIONS, FLOG, POINTLOG] = GRADDESC(F, X, OPTIONS, GRADF) uses
%	batch gradient descent to find a local minimum of the function  F(X)
%	whose gradient is given by GRADF(X). A log of the function values
%	after each cycle is (optionally) returned in ERRLOG, and a log of the
%	points visited is (optionally) returned in POINTLOG.
%
%	Note that X is a row vector and F returns a scalar value.  The point
%	at which F has a local minimum is returned as X.  The function value
%	at that point is returned in OPTIONS(8).
%
%	GRADDESC(F, X, OPTIONS, GRADF, P1, P2, ...) allows  additional
%	arguments to be passed to F() and GRADF().
%
%	The optional parameters have the following interpretations.
%
%	OPTIONS(1) is set to 1 to display error values; also logs error
%	values in the return argument ERRLOG, and the points visited in the
%	return argument POINTSLOG. If OPTIONS(1) is set to 0, then only
%	warning messages are displayed.  If OPTIONS(1) is -1, then nothing is
%	displayed.
%
%	OPTIONS(2) is the absolute precision required for the value of X at
%	the solution.  If the absolute difference between the values of X
%	between two successive steps is less than OPTIONS(2), then this
%	condition is satisfied.
%
%	OPTIONS(3) is a measure of the precision required of the objective
%	function at the solution.  If the absolute difference between the
%	objective function values between two successive steps is less than
%	OPTIONS(3), then this condition is satisfied. Both this and the
%	previous condition must be satisfied for termination.
%
%	OPTIONS(7) determines the line minimisation method used.  If it is
%	set to 1 then a line minimiser is used (in the direction of the
%	negative gradient).  If it is 0 (the default), then each parameter
%	update is a fixed multiple (the learning rate) of the negative
%	gradient added to a fixed multiple (the momentum) of the previous
%	parameter update.
%
%	OPTIONS(9) should be set to 1 to check the user defined gradient
%	function GRADF with GRADCHEK.  This is carried out at the initial
%	parameter vector X.
%
%	OPTIONS(10) returns the total number of function evaluations
%	(including those in any line searches).
%
%	OPTIONS(11) returns the total number of gradient evaluations.
%
%	OPTIONS(14) is the maximum number of iterations; default 100.
%
%	OPTIONS(15) is the precision in parameter space of the line search;
%	default FOPTIONS(2).
%
%	OPTIONS(17) is the momentum; default 0.5.  It should be scaled by the
%	inverse of the number of data points.
%
%	OPTIONS(18) is the learning rate; default 0.01.  It should be scaled
%	by the inverse of the number of data points.
%
%	See also
%	CONJGRAD, LINEMIN, OLGD, MINBRACK, QUASINEW, SCG
%

%	Copyright (c) Ian T Nabney (1996-2001)

%  Set up the options.
if length(options) < 18
  error('Options vector too short')
end

if (options(14))
  niters = options(14);
else
  niters = 100;
end

line_min_flag = 0; % Flag for line minimisation option
if (round(options(7)) == 1)
  % Use line minimisation
  line_min_flag = 1;
  % Set options for line minimiser
  line_options = foptions;
  if options(15) > 0
    line_options(2) = options(15);
  end
else
  % Learning rate: must be positive
  if (options(18) > 0)
    eta = options(18);
  else
    eta = 0.01;
  end
  % Momentum term: allow zero momentum
  if (options(17) >= 0)
    mu = options(17);
  else
    mu = 0.5;
  end
end

% Check function string
f = fcnchk(f, length(varargin));
gradf = fcnchk(gradf, length(varargin));

% Display information if options(1) > 0
display = options(1) > 0;

% Work out if we need to compute f at each iteration.
% Needed if using line search or if display results or if termination
% criterion requires it.
fcneval = (options(7) | display | options(3));

%  Check gradients
if (options(9) > 0)
  feval('gradchek', x, f, gradf, varargin{:});
end

dxold = zeros(1, size(x, 2));
xold = x;
fold = 0; % Must be initialised so that termination test can be performed
if fcneval
  fnew = feval(f, x, varargin{:});
  options(10) = options(10) + 1;
  fold = fnew;
end

%  Main optimization loop.
for j = 1:niters
  xold = x;
  grad = feval(gradf, x, varargin{:});
  options(11) = options(11) + 1;  % Increment gradient evaluation counter
  if (line_min_flag ~= 1)
    dx = mu*dxold - eta*grad;
    x =  x + dx;
    dxold = dx;
    if fcneval
      fold = fnew;
      fnew = feval(f, x, varargin{:});
      options(10) = options(10) + 1;
    end
  else
    sd = - grad./norm(grad);	% New search direction.
    fold = fnew;
    % Do a line search: normalise search direction to have length 1
    [lmin, line_options] = feval('linemin', f, x, sd, fold, ...
      line_options, varargin{:});
    options(10) = options(10) + line_options(10);
    x = xold + lmin*sd;
    fnew = line_options(8);
  end
  if nargout >= 3
    flog(j) = fnew;
    if nargout >= 4
      pointlog(j, :) = x;
    end
  end
  if display
    fprintf(1, 'Cycle  %5d  Function %11.8f\n', j, fnew);
  end
  if (max(abs(x - xold)) < options(2) & abs(fnew - fold) < options(3))
    % Termination criteria are met
    options(8) = fnew;
    return;
  end
end

if fcneval
  options(8) = fnew;
else
  options(8) = feval(f, x, varargin{:});
  options(10) = options(10) + 1;
end
if (options(1) >= 0)
  disp(maxitmess);
end
