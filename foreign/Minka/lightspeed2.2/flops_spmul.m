function f = flops_spmul(a,b)
% FLOPS_SPMUL    Flops for sparse matrix multiplication.
% FLOPS_SPMUL(a,b) returns the number of flops for a*b, where multiplication
% and addition of zero doesn't count.
% For example:
%   flops_spmul(0,4) is 0.
%   flops_spmul([1 0 1], [2;3;4]) is 3.
%   flops_spmul(eye(3), [2;3;4]) is 3.

nza = (a ~= 0);
nzb = (b ~= 0);
f = nza*nzb;
f = 2*f - (f ~= 0);
f = sum(sum(f));
