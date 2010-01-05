function f = flops_chol(n)
% FLOPS_CHOL    Flops for Cholesky decomposition.
% FLOPS_CHOL(n) returns the number of flops for chol(eye(n)).

% Formula comes from Numerical Recipes algorithm.
% Number of multiplies+adds is:
% sum(i=1..n) sum(j=i..n) sum(k=i-1..1) 2 = sum(i=1..n) 2*(n-i+1)*(i-1)
% = (n^3-n)/3 = maple('simplify(sum(2*(n-x+1)*(x-1),x=1..n));')
% Number of divides is:
% sum(i=1..n) (n-i+1) - n = (n^2-n)/2

% matlab5 counts n^3/3 only
f = (n.^3-n)/3 + (n.^2-n)/2*flops_div + n*flops_sqrt;
