function f = flops_row_sum(n,m)
% FLOPS_ROW_SUM         Flops for row sums.
% FLOPS_ROW_SUM(a) returns the number of flops for row_sum(a).
% FLOPS_ROW_SUM(n,m) returns the number of flops for row_sum(ones(n,m)).

if nargin == 1
  m = cols(n);
  n = rows(n);
end
f = n*(m-1);
