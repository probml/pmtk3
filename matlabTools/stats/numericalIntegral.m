function val = numericalIntegral(f, range, tol)
% Evalaute an integral using quad, dblquad or triple quad
% f must be a function that takes an n*1, n*2 or n*3 matrix
% and returns the function value at the specified points.
% range is [x1min x1max x2min x2max x3min x3max]

% This file is from pmtk3.googlecode.com


if nargin < 3, tol = 1e-3; end
ndims = length(range)/2;
switch ndims
  case 1,
    foo = @(x) f(x(:)); % quad passes in 1 row vector
    val = quad(foo, range(1), range(2), tol);
  case 2,
    foo = @(x1,x2) f(replicateX(x1,x2));
    val = dblquad(foo, range(1), range(2), range(3), range(4), tol);
  case 3,
    foo = @(x1,x2,x3) f(replicateX(x1,x2,x3));
    val = triplequad(foo, range(1), range(2), range(3), range(4), range(5), range(6), tol);
  otherwise
    error('can only handle up to 3d')
end
end

% dblquad calls f with vectorized first argument but scalar second
% Here we may all argumetns have the same shape
function X = replicateX(x1, x2, x3)
%  X(i,:) = [x1(i) x2] or [x1(i) x2 x3]
n = length(x1);
x2 = x2*ones(n,1);
if nargin == 3
  x3 = x3*ones(n,1);
  X = [x1(:) x2(:) x3(:)];
else
  X = [x1(:) x2(:)];
end
end

 
