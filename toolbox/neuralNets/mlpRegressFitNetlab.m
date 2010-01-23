function [model, output] = mlpRegressFitNetlab(X, y, H, lambda, options)
% Train a multi-layer perceptron; needs netlab and minFunc
% X is an N*D matrix of inputs
% y should be a N*K matrix of reals 
% H is the number of hidden nodes (single layer)
% lambda is the strength of the L2 regularizer on the weights (not biases)
% output is the return value from minFunc

[model, output] = mlpGenericFitNetlab(X, y, H, lambda, options, 'linear');