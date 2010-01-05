function [p1, yhat01, yhatpm] = logregPredict(X,w)
% p1(i) = p(y=1|X(i,:), w)
% yhat01 = 1 if p1>0.5 otherwise   0 
% yhatpm = 1 if p1>0.5 otherwise -1
% A column of 1s is added to X


N = size(X,1);
X = [ones(N,1) X];
p1 = sigmoid(X*w);
yhat01 = p1>=0.5;
yhatpm = 1*(p1>=0.5) + -1*(p1<0.5);
