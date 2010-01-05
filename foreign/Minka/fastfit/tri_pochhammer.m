function y = tri_pochhammer(x,n)
% tri_pochhammer(x,n) returns trigamma(x+n) - trigamma(x),
% with special attention to the case n==0.

if 0 & length(x) == 1 & all(n < 100)
  nmax = full(max(max(n)));
  t(1) = 0;
  y = 0;
  for i = 1:nmax
    y = y - 1/(x*x);
    t(i+1) = y;
    x = x + 1;
  end
  y = t(n+1);
  % workaround matlab's silly rules for matrix indexing
  if cols(n) == 1
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
  y(i) = trigamma(x+n(i)) - trigamma(x);
else
  y(i) = trigamma(x(i)+n(i)) - trigamma(x(i));
end

