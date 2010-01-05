function f = flops_pow(a)
% FLOPS_POW    Flops for raising to real power.
% FLOPS_POW(A) returns the number of flops for (X .^ A) where X is scalar.
% Powers like 0, 1, 2, and 1/2 are handled specially.

flops_div = 8;
flops_sqrt = 8;
if nargin < 1
  a = 0.1;
end
f = 0;
if a < 0
  f = f + flops_div;
  a = -a;
end
if a == 0 || a == 1
  return;
end
if fix(a) == a
  % number of multiplications to raise to integer power
  f = f + floor(log2(a)) + num_bits(a)-1;
elseif a == 1/2
  % sqrt is built-in function
  f = f + flops_sqrt;
elseif fix(2*a) == 2*a
  % this handles flops_pow(1/2+1)
  f = f + flops_pow(2*a) - 1 + flops_sqrt;
elseif a == 1/4
  f = f + 2*flops_sqrt;
elseif a == 3/4
  f = f + 2*flops_sqrt+1;
elseif fix(4*a) == 4*a
  % this handles flops_pow(1/4+1)
  f = f + flops_pow(2*a) - 1 + flops_sqrt;
else
  f = Inf;
end

% The identities
%   exp(a) = e^a
%   a^b = exp(b*log(a))
% require that
%   flops_exp < flops_pow < flops_exp+flops_log+1.
% But in practice, I find that the runtime exceeds this upper bound.

f_upper = 61;  % flops_exp+flops_log+1
if f > f_upper
  f = f_upper;
end


function b = num_bits(x)
% Returns the number of 1 bits in the binary representation of x.
% x must be a non-negative integer.

% lookup table for 0-15
bits = [0 1 1 2 1 2 2 3 1 2 2 3 2 3 3 4];

b = 0;
while(x > 0)
  b = b + bits(mod(x,16)+1);
  x = floor(x/16);
end
