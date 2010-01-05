function f = flops_sqrt
% FLOPS_SQRT    Flops for square root
% FLOPS_SQRT returns the number of flops needed to compute the square root
% of a scalar. 

% This flop count is based on timing the Pentium 4.
% The neutral flop count is based on source code for C sqrt() function at
% http://www.opencores.org/cvsweb.shtml/or1k/newlib/newlib/libm/mathfp/s_sqrt.c

% if you change this, you should also change flops_pow.
f = 8; % P4
%f = 15; % neutral

