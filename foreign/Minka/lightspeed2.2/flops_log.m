function f = flops_log
% FLOPS_LOG    Flops for logarithm
% FLOPS_LOG returns the number of flops needed to compute the logarithm
% of a scalar.  

% This flop count is based on timing the Pentium 4.
% A neutral flop count is based on source code for C log() function at
% http://www.opencores.org/cvsweb.shtml/or1k/newlib/newlib/libm/mathfp/s_log.c
% s_sine.c is 23 flops.

% if you change this, you should also change flops_pow.
f = 20;  % P4
%f = 20;  % neutral
