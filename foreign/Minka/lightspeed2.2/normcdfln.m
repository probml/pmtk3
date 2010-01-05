function e = normcdfln(x)
% NORMCDFLN   log of normal cumulative density function.
% More accurate than log(normcdf(x)) when x is small.
% The following is a quick and dirty approximation to normcdfln:
% normcdfln(x) =approx -(log(1+exp(0.88-x))/1.5)^2

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

% make e the same shape as x, and inherit any NaNs.
e = x;
t = -6.5;
i = find(x >= t);
if ~isempty(i)
  e(i) = log(normcdf(x(i)));
end
i = find(x < t);
if ~isempty(i)
  x = x(i);
  z = x.^(-2);
  if 0
    % log of asymptotic series for cdf
    % subs(x=-x,asympt(sqrt(2*Pi)*gauss_cdf(-x),x));
    c = [-1 3 -15 105 -945 10395 -135135 2027025 -34459425 654729075];
    y = 0;
    for i = length(c):-1:1
      y = z.*(y + c(i));
    end
    %y = z.*(c(1)+z.*(c(2)+z.*(c(3)+z.*(c(4)+z.*(c(5)+z.*(c(6)+z.*c(7)))))));
    y = log(1+y);
  else
    % asymptotic series for logcdf
    % subs(x=-x,asympt(log(gauss_cdf(-x)),x));
    c = [-1 5/2 -37/3 353/4 -4081/5 55205/6 -854197/7];
    y = z.*(c(1)+z.*(c(2)+z.*(c(3)+z.*(c(4)+z.*(c(5)+z.*(c(6)+z.*c(7)))))));
  end
  e(i) = y -0.5*log(2*pi) -0.5*x.^2 - log(-x);
end
