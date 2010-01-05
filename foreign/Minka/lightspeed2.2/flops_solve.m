function f = flops_solve(a,b,c)
% FLOPS_SOLVE    Flops for matrix left division.
% FLOPS_SOLVE(a,b) returns the number of flops for a\b.
% FLOPS_SOLVE(n,m,c) returns the number of flops for ones(n,m)\ones(m,c).

if nargin == 2
  f = flops_solve(rows(a),cols(a),cols(b));
  return;
end
if a == b
  if a == 1
    % scalar division
    f = c*flops_div;
    return;
  end
  f = flops_chol(a) + 2*flops_solve_tri(a,b,c);
elseif a > b
  % this comes from Ax=b, x = (A'*A)\(A'*b)
  f = flops_mul(b,a,b) + flops_mul(b,a,c) + flops_solve(b,b,c);
else
  % this comes from Ax=b, x = A'*(A*A')\b
  f = flops_mul(a,b,a) + flops_mul(b,a,c) + flops_solve(a,a,c);
end
