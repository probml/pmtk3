function [yhat, py] = mlpClassifPredictNetlab(model, X)
% Prediction for multi-layer perceptron for  classification
% yhat(i,:) is  0 or 1
% py(i,:) = p(y=1|X(i,:))

[py] = mlpfwd(model.net, X);
[junk, yhat] = max(py,[],2); %#ok