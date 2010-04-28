function [model, output] = mlpClassifFitNetlab(X, y, H, lambda, options)
% Train a multi-layer perceptron; needs netlab and minFunc
% X is an N*D matrix of inputs
% y should be a N*K matrix containing 0,1 (1 of K encoding)
% H is the number of hidden nodes (single layer)
% lambda is the strength of the L2 regularizer on the weights (not biases)
% output is the return value from minFunc

K = size(y,2);
if K==1
  [model, output] = mlpGenericFitNetlab(X, y, H, lambda, options, 'logistic');
else
  [model, output] = mlpGenericFitNetlab(X, y, H, lambda, options, 'softmax');
end

end