
function [w, bias] = linregL2FitNoOffset(X, y, lambda)
% Ridge regression
% No offset is added
[N,D] = size(X);
lambdaVec = lambda*ones(D,1);
XX  = [X; diag(sqrt(lambdaVec))];
yy = [y; zeros(D,1)];
w  = XX \ yy; % QR
bias = 0;

