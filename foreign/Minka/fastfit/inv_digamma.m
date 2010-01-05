function x = inv_digamma(y,niter)
% INV_DIGAMMA    Inverse of the digamma function.
%
% inv_digamma(y) returns x such that digamma(x) = y.

% a different algorithm is provided by Paul Fackler:
% http://www.american.edu/academic.depts/cas/econ/gaussres/pdf/loggamma.src

% Newton iteration to solve digamma(x)-y = 0
x = exp(y)+1/2;
i = find(y <= -2.22);
x(i) = -1./(y(i) - digamma(1));

% never need more than 5 iterations
if nargin < 2
  niter = 5;
end
for iter = 1:niter
  x = x - (digamma(x)-y)./trigamma(x);
end
return

% test
y = -3:0.01:0.1;
x = digamma(inv_digamma(y));
max(abs(x-y))
max(abs(x-y)./inv_digamma(y))
