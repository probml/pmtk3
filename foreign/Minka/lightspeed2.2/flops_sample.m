function f = flops_sample(p,n)
% FLOPS_SAMPLE   Flops for sample(p,n)
% Flopcount based on systematic sampling.

% old algorithm:
% The flopcount for sample is the same as the value returned by sample,
% so the expected flops is E[x].
% Note that the result is typically not an integer.

if nargin == 1
  n = 1;
end
%f = n*sum((1:length(p)).*p);
f = 2*(n + length(p));
