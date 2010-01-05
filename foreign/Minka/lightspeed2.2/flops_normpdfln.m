function f = flops_normpdfln(x, m, S, V)
% FLOPS_NORMPDFLN   Flops for normpdfln.
% Arguments are same as normpdf.

f = 0;
if nargin == 1
  [d,n] = size(x);
elseif isempty(m)
  [d,n] = size(x);
else
  s = max(size(x),size(m));
  d = s(1);
  n = s(2);
  f = f + d*n;
end
if nargin < 3
  f = f + d*n + (d-1)*n + 2*n;
  return
end
have_inv = 0;
if nargin == 3
  if d == 1
    f = f + (3+flops_div)*n + cols(S) + (1+flops_log)*cols(S);
    return;
  end
else
  if ischar(V)
    if strcmp(V,'inv')
      have_inv = 1;
    end
  elseif ischar(S)
    if strcmp(S,'inv')
      f = f + flops_chol(d);
      have_inv = 1;
    end
  else
    f = f + flops_chol(d);
  end
end
if have_inv
  % count flops for log(prod) instead of sum(log)
  f = f + flops_mul(d,d,n) + d-1 + flops_log;
else
  f = f + flops_solve_tri(d,d,n) + d-1 + flops_log;
end
f = f + 1 + d*n + (d-1)*n + 2*n;
