function [a,b] = negbin_fit(x,w,t)
% NEGBIN_FIT  Maximum-likelihood (generalized) negative binomial distribution.
%
% NEGBIN_FIT(x) returns the MLE (a,b) for the samples in vector x.
% The length of x is the number of samples.
%
% NEGBIN_FIT(x,w) returns the MLE (a,b) for samples weighted by w.
% Typically, x is 0:max and w is a histogram over the x's.
% The number of samples is sum(w).
%
% NEGBIN_FIT(x,w,t), where x and t are the same length, returns the MLE (a,b)
% for a generalized negative binomial distribution.  
% In this distribution, t(i) is the `waiting time' for x(i), so that t = 1 is 
% the ordinary negative binomial.
% The generalized distribution is 
%   p(x|t,a,b) = choose(x+a-1,x) p^x (1-p)^a
% where p = bt/(bt+1).
% If w is empty, it is assumed to be ones(size(x)).
%
% The algorithm is EM, with gamma_fit performing the M-step.

if nargin < 3 | isempty(t)
  t = ones(size(x));
end
if nargin < 2 | isempty(w)
  w = ones(size(x));
end
xt = x./t;
w = w/sum(w);
m = sum(w.*xt);
v = sum(w.*(xt - m).^2);
b = v/m - 1;
if b < 0
  b = 1e-3;
end
a = m/b;
% EM alg
for iter = 1:100
  old_a = a;
  % E step
  p = b./(1+b*t);
  m = sum(w.*(x+a).*p);
  s = log(m) - sum(w.*(digamma(x+a) + log(p)));
  % M-step
  [a,b] = gamma_fit(m,s);
  if abs(a - old_a) < 1e-8
    break
  end
end
if iter == 100
  warning('not enough iters')
end

if 0
% gen Newton
% only works if the initialization is good
m = mean(x);
for iter = 1:100
  old_a = a;
  g = mean(digamma(x+a)) - digamma(a) + log(a/(a+m));
  h = mean(trigamma(x+a)) - trigamma(a) + 1/a - 1/(a+m);
  a = 1/(1/a + g/(a^2*h));
  if abs(a - old_a) < 1e-8
    break
  end
end
b = m/a;
p = b/(b+1);
end

end