function [a,b] = gamMOM(X)
% method of moments estimate for Gamma
% a = shape, b= rate

% This file is from pmtk3.googlecode.com

xbar = mean(X);
s2hat = var(X);
a = xbar^2/s2hat;
b  = xbar/s2hat;

end
