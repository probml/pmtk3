function [w] = linregRobustHuberFit(X, y, delta)
% Minimize Huber loss function for linear regression
% We assume X is an N*D matrix; we will add a column of 1s internally
% w = [w0 w1 ... wD] is a column vector, where w0 is the bias

%#author Mark Schmidt
%#url http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html#2

if nargin < 3, delta = 1; end
n = size(X,1);
XX = [ones(n,1) X];
wLS = XX \ y; % initialize with least squares
options.Display = 'none';
w = minFunc(@HuberLoss,wLS,options,XX,y,delta);