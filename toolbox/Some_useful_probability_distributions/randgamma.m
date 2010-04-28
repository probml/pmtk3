function x = randgamma(a)
% RANDGAMMA   Sample from Gamma distribution
% 
% X = RANDGAMMA(A) returns a matrix, the same size as A, where X(i,j)
% is a sample from a Gamma(A(i,j)) distribution.
%
% Gamma(a) has density function p(x) = x^(a-1)*exp(-x)/gamma(a).

% This function is implemented in MEX (randgamma.c)
error('You must run install_lightspeed first');
