function [X, knots] = splineBasis(x, K, knots)
%% Spline basis function expansion

% This file is from pmtk3.googlecode.com


if nargin < 2, K = 100; end
if nargin < 3, knots = linspace(min(x), max(x), K); end
K = length(knots);
d = length(knots);
[junk, bind] = histc(x,knots);
n = length(x);
X = sparse((1:n)',bind,1,n,d); % design matrix


end
