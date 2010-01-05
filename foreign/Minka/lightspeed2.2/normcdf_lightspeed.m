function p = normcdf(x,m,s)
%NORMCDF   Normal Cumulative Density Function.
% P = NORMCDF(X) returns the probability that a standard normal variate will
% be less than X.
%
% P = NORMCDF(X,M,S) returns the probability that a normal variate with
% mean M and standard deviation S will be less than x.

if nargin > 1
  if nargin == 3
    x = (x-m)./s;
  else
    error('Usage: normcdf(x,m,s)');
  end
end

p = 0.5*erf(x/sqrt(2)) + 0.5;
