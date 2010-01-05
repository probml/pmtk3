function y = pochhammer(x,n)
% pochhammer(x,n) returns the rising log-factorial log(gamma(x+n)/gamma(x))
% Named after the corresponding Mathematica function.
%
% pochhammer.c provides a faster implementation.

if 0 && length(x) == 1 && all(n < 100)
  nmax = full(max(max(n)));
  t(1) = 0;
  y = 0;
  for i = 1:nmax
    y = y + log(x);
    t(i+1) = y;
    x = x + 1;
  end
  y = t(n+1);
  % workaround matlab's silly rules for matrix indexing
  if cols(n) == 1 & rows(y) == 1
    y = y';
  end
  return
end
if issparse(n)
  y = sparse(rows(n),cols(n));
else
  y = zeros(size(n));
end
i = (n > 0);
if length(x) == 1
  y(i) = gammaln(x+n(i)) - gammaln(x);
else
  y(i) = gammaln(x(i)+n(i)) - gammaln(x(i));
end
