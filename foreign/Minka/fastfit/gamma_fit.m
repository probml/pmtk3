function [a,b] = gamma_fit(x,s)
% GAMMA_FIT     Maximum-likelihood gamma distribution.
%
% GAMMA_FIT(x) returns the MLE (a,b) for the data in vector x.
%
% GAMMA_FIT(m,s) returns the MLE (a,b) for data with sufficient statistics
% given by 
%   m = mean(x)
%   s = log(m) - mean(log(x))
%
% The gamma distribution is parameterized as
%   p(x) = x^(a-1)/(Gamma(a) b^a) exp(-x/b)
%   E[x] = ab
%
% The algorithm is a generalized Newton iteration, described in
% "Estimating a Gamma distribution" by T. Minka.

% Written by Tom Minka

if nargin == 1
  m = mean(x);
  s = log(m) - mean(log(x));
else
  % suff stats given
  m = x;
end
a = 0.5/s;
if 0
  % lower bound
  for iter = 1:1000
    old_a = a;
    a = inv_digamma(log(a) - s);
    if(abs(a - old_a) < 1e-8) break, end
  end
end

% gen Newton
for iter = 1:100
  old_a = a;
  g = log(a)-s-digamma(a);
  h = 1/a - trigamma(a);
  a = 1/(1/a + g/(a^2*h));
  if(abs(a - old_a) < 1e-8) break, end
end  
b = m/a;
end