function f = flops_col_sum(n,m)
% FLOPS_COL_SUM         Flops for column sums.
% FLOPS_COL_SUM(a) returns the number of flops for col_sum(a).
% FLOPS_COL_SUM(n,m) returns the number of flops for col_sum(ones(n,m)).

if nargin == 1
  m = cols(n);
  n = rows(n);
end
f = (n-1)*m;
