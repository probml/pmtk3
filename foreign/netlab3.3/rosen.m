function y = rosen(x)
%ROSEN	Calculate Rosenbrock's function.
%
%	Description
%	Y = ROSEN(X) computes the value of Rosenbrock's function at each row
%	of X, which should have two columns.
%
%	See also
%	DEMOPT1, ROSEGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Calculate value of Rosenbrock's function: x should be nrows by 2 columns

y = 100 * ((x(:,2) - x(:,1).^2).^2) + (1.0 - x(:,1)).^2;
