function [yhat01, p1] = logregPredict(model, X)
% p1(i) = p(y=1|X(i,:), w)
% yhat01 = 1 if p1>0.5 otherwise 0 
% A column of 1s is added if this was done at training time

N = size(X,1);
if model.includeOffset
  X = [ones(N,1) X];
end
p1 = sigmoid(X*model.w);
yhat01 = p1>=0.5;

