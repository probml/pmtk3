function y = linef(lambda, fn, x, d, varargin)
%LINEF	Calculate function value along a line.
%
%	Description
%	LINEF(LAMBDA, FN, X, D) calculates the value of the function FN at
%	the point X+LAMBDA*D.  Here X is a row vector and LAMBDA is a scalar.
%
%	LINEF(LAMBDA, FN, X, D, P1, P2, ...) allows additional arguments to
%	be passed to FN().   This function is used for convenience in some of
%	the optimisation routines.
%
%	See also
%	GRADCHEK, LINEMIN
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check function string
fn = fcnchk(fn, length(varargin));

y = feval(fn, x+lambda.*d, varargin{:});
