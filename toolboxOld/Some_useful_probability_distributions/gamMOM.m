function [a,b] = gamMOM(X)
% method of moments estimate for Gamma
% a = shape, b= rate
xbar = mean(X);
s2hat = var(X);
a = xbar^2/s2hat;
b  = xbar/s2hat;

end