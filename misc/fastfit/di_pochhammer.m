function y = di_pochhammer(x,n)
% di_pochhammer(x,n) returns digamma(x+n)-digamma(x), 
% with special attention to the case n==0.
%
% di_pochhammer.c provides a faster implementation.

if issparse(n)
  y = sparse(rows(n),cols(n));
else
  y = zeros(size(n));
end
i = (n > 0);
if length(x) == 1
  y(i) = digamma(x+n(i)) - digamma(x);
else
  y(i) = digamma(x(i)+n(i)) - digamma(x(i));
end

end