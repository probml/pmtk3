function [X, knots] = splineBasis(x, K)
%% Spline basis function expansion
if nargin < 2, K = 100; end

knots = linspace(min(x), max(x), K);
d = length(knots);
[junk, bind] = histc(x,knots);
n = length(x);
X = sparse((1:n)',bind,1,n,d); % design matrix


end