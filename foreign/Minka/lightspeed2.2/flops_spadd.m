function f = flops_spadd(a,b)
% FLOPS_SPADD   Flops for sparse matrix addition.
% FLOPS_SPADD(a,b) returns the number of flops for a+b, where addition of zero
% doesn't count.
% For example:
%   flops_spadd(0,4) is 0.
%   flops_spadd(eye(3), ones(3)) is 3.

nza = (a ~= 0);
nzb = (b ~= 0);
f = sum(sum(nza & nzb));
