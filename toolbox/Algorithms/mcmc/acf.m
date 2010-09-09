function y=acf(x,lagmax)
%ACF Autocorrelation function
% ACF(X,maxlag)

% This file is from pmtk3.googlecode.com


x = x(:)'-mean(x);
n = length(x);
if nargin<2
  lagmax = n-1;
end
y  = conv(fliplr(x),x);
y = y(1:n);
y = y(n:-1:1)/n;
s2 = y(1);
assert(approxeq(s2, var(x,1)))
y = y/s2;
y = y(1:lagmax+1);

end
