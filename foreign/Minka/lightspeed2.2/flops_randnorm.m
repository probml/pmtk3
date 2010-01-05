function f = flops_randnorm(n, m, S, V)
% FLOPS_RANDNORM     Flops for randnorm.
% Arguments same as randnorm.

flops_randn = 18;
if nargin == 1
  f = n*flops_randn;
  return;
end
d = rows(m);
f = d*n*flops_randn;
if nargin > 2
  if nargin == 4
    if d == 1
      f = f + flops_sqrt*cols(S);
    else
      f = f + flops_chol(d);
    end
  end
  f = f + flops_mul(d,d,n);
end
f = f + d*n;
