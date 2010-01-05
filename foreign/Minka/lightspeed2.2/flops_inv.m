function f = flops_inv(n)
% FLOPS_INV    Flops for matrix inversion.
% FLOPS_INV(n) returns the number of flops for inv(eye(n)).
% It assumes the matrix is positive definite, since this allows the
% fastest inverse.

f = flops_solve(n,n,n);


