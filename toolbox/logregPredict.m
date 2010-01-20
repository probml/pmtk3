function [yhat01, p1] = logregPredict(X,w, addOnes)
% p1(i) = p(y=1|X(i,:), w)
% yhat01 = 1 if p1>0.5 otherwise   0 
% A column of 1s is added to X by default

if nargin < 3, addOnes = true; end
N = size(X,1);
if addOnes
  X = [ones(N,1) X];
end
p1 = sigmoid(X*w);
yhat01 = p1>=0.5;
%yhatpm = 1*(p1>=0.5) + -1*(p1<0.5);
