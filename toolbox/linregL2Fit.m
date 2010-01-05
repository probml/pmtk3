
function [w, bias] = linregL2Fit(X, y, lambda, includeOffset)
% Ridge regression
% adds a column of 1s if incldueOffset=1 (default)
if nargin < 4, includeOffset = true; end
[N,D] = size(X);
if includeOffset
   X = [ones(N,1) X];
   D1  = D+1;
else 
   D1 = D;
end
lambdaVec = lambda*ones(D1,1);
if includeOffset
   lambdaVec(1) = 0; % Don't penalize bias term
end
XX  = [X; diag(sqrt(lambdaVec))];
yy = [y; zeros(D1,1)];
w  = XX \ yy; % QR
if includeOffset
   bias = w(1);
   w = w(2:end);
else
   bias = 0;
end


