function [yhat, p1] = logregPredict(model, X)
% p1(i) = p(y=1|X(i,:), w)
% yhat - same space as model.ySupport
% A column of 1s is added if this was done at training time

N = size(X,1);
if model.includeOffset
  X = [ones(N,1) X];
end
p1 = sigmoid(X*model.w);
yhat01 = p1>=0.5;
yhat(yhat01 == 0) = model.ySupport(1);
yhat(yhat01 == 1) = model.ySupport(2); 
yhat = colvec(yhat); 

