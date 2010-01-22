function L = factorialln(n)
% L(i) = log n(i)!

% n! = gamma(n+1)
L= gammaln(n + 1);