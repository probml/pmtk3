function p = wishpdf(varargin)
%WISHPDF     Wishart probability density function.
% WISHPDF(X,A) returns the density at X under a Wishart distribution with 
% shape parameter A and unit scale parameter.  
% X is a positive definite matrix and A is scalar.
% WISHPDF(X,A,B) specifies the scale parameter of the distribution (a 
% positive definite matrix with the same size as X).
%
% The probability density function has the form:
% p(X) = |X|^(a-(d+1)/2)*exp(-tr(X*B))*|B|^a/Gamma_d(a)
% where Gamma_d is the multivariate Gamma function.
%
% WISHPDF(X,A,B,'inv') returns the density at X under an inverse Wishart
% distribution.  The probability density function for an inverse Wishart is:
% p(X) = |X|^(-a-(d+1)/2)*exp(-tr(inv(X)*B))*|B|^a/Gamma_d(a)

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

p = exp(wishpdfln(varargin{:}));
