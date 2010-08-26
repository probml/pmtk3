function [yhat, py] = mlpClassifPredict(model, X)
% Multi-layer perceptron for binary classification
% yhat is  0 or 1
% py(i) = p(y=1|X(i,:))
[yhat, py] = mlpClassifPredictSchmidt(model, X);
end