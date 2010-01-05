function f = flops_exp
% FLOPS_EXP    Flops for exponential
% FLOPS_EXP returns the number of flops needed to compute the exponential
% of a scalar.

% This flop count is based on timing the Pentium 4.
% A neutral flop count is based on source code for C exp() function at
% http://www.opencores.org/cvsweb.shtml/or1k/newlib/newlib/libm/mathfp/s_exp.c

% if you change this, you should also change flops_pow.
f = 40;  % P4
%f = 20; % neutral
