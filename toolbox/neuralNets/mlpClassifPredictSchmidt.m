function [yhat, py] = mlpClassifPredict(model, X)
% Multi-layer perceptron for binary classification
% yhat is  0 or 1
% py(i) = p(y=1|X(i,:))

[N,D] = size(X);
X = [ones(N,1) X];
mu = MLPregressionPredict(model.w, X, model.nHidden);
yhat = mu>0;
if nargout >= 2
  py = sigmoid(mu);
end