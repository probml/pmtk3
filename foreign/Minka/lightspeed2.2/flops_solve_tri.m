function f = flops_solve_tri(T,b,c)
% FLOPS_SOLVE_TRI   Flops for triangular left division.
% FLOPS_SOLVE_TRI(T,b) returns the number of flops for solve_tri(T,b).
% FLOPS_SOLVE_TRI(n,n,m) returns the number of flops for 
% solve_tri(eye(n),ones(n,m)).

if nargin == 2
  f = flops_solve_tri(rows(T),cols(T),cols(b));
  return;
end
% number of multiplies+adds is
% sum(i=1..n) sum(k=i-1..1) 2 = sum(i=1..n) 2*(i-1) = n^2-n
% number of divides is n
f = (T*b + b*(flops_div-1))*c;
