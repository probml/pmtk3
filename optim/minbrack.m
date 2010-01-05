function  [br_min, br_mid, br_max, num_evals] = minbrack(f, a, b, fa,  ...
			 varargin)
%MINBRACK Bracket a minimum of a function of one variable.
%
%	Description
%	BRMIN, BRMID, BRMAX, NUMEVALS] = MINBRACK(F, A, B, FA) finds a
%	bracket of three points around a local minimum of F.  The function F
%	must have a one dimensional domain. A < B is an initial guess at the
%	minimum and maximum points of a bracket, but MINBRACK will search
%	outside this interval if necessary. The bracket consists of three
%	points (in increasing order) such that F(BRMID) < F(BRMIN) and
%	F(BRMID) < F(BRMAX). FA is the value of the function at A: it is
%	included to avoid unnecessary function evaluations in the
%	optimization routines. The return value NUMEVALS is the number of
%	function evaluations in MINBRACK.
%
%	MINBRACK(F, A, B, FA, P1, P2, ...) allows additional arguments to be
%	passed to F
%
%	See also
%	LINEMIN, LINEF
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check function string
f = fcnchk(f, length(varargin));

% Value of golden section (1 + sqrt(5))/2.0
phi = 1.6180339887499;

% Initialise count of number of function evaluations
num_evals = 0;

% A small non-zero number to avoid dividing by zero in quadratic interpolation
TINY = 1.e-10;

% Maximal proportional step to take: don't want to make this too big
% as then spend a lot of time finding the minimum inside the bracket
max_step = 10.0;

fb = feval(f, b, varargin{:});
num_evals = num_evals + 1;

% Assume that we know going from a to b is downhill initially 
% (usually because gradf(a) < 0).
if (fb > fa)
  % Minimum must lie between a and b: do golden section until we find point
  % low enough to be middle of bracket
  c = b;
  b = a + (c-a)/phi;
  fb = feval(f, b, varargin{:});
  num_evals = num_evals + 1;
  while (fb > fa)
    c = b;
    b = a + (c-a)/phi;
    fb = feval(f, b, varargin{:});
    num_evals = num_evals + 1;
  end
else  
  % There is a valid bracket upper bound greater than b
  c = b + phi*(b-a);
  fc = feval(f, c, varargin{:});
  num_evals = num_evals + 1;
  bracket_found = 0;
  
  while (fb > fc)
    % Do a quadratic interpolation (i.e. to minimum of quadratic)
    r = (b-a).*(fb-fc);
    q = (b-c).*(fb-fa);
    u = b - ((b-c)*q - (b-a)*r)/(2.0*(sign(q-r)*max([abs(q-r), TINY])));
    ulimit = b + max_step*(c-b);
    
    if ((b-u)'*(u-c) > 0.0)
      % Interpolant lies between b and c
      fu = feval(f, u, varargin{:});
      num_evals = num_evals + 1;
      if (fu < fc)
	% Have a minimum between b and c
	br_min = b;
	br_mid = u;
	br_max = c;
	return;
      elseif (fu > fb)
	% Have a minimum between a and u
	br_min = a;
	br_mid = c;
	br_max = u;
	return;
      end
      % Quadratic interpolation didn't give a bracket, so take a golden step
      u = c + phi*(c-b);
    elseif ((c-u)'*(u-ulimit) > 0.0)
      % Interpolant lies between c and limit
      fu = feval(f, u, varargin{:});
      num_evals = num_evals + 1;
      if (fu < fc)
	% Move bracket along, and then take a golden section step
	b = c;
	c = u;
	u = c + phi*(c-b);
      else
	bracket_found = 1;
      end
    elseif ((u-ulimit)'*(ulimit-c) >= 0.0)
      % Limit parabolic u to maximum value
      u = ulimit;
    else
      % Reject parabolic u and use golden section step
      u = c + phi*(c-b);
    end
    if ~bracket_found
      fu = feval(f, u, varargin{:});
      num_evals = num_evals + 1;
    end
    a = b; b = c; c = u;
    fa = fb; fb = fc; fc = fu;
  end % while loop
end   % bracket found
br_mid = b;
if (a < c)
  br_min = a;
  br_max = c;
else
  br_min = c; 
  br_max = a;
end
