function [model, output] = mlpRegressFit(X, y, nHidden, lambda, options)
% Multi-layer perceptron for regression; fit using minFunc
% nHidden can be a vector of integers if there are multiple laters
% We currenly assume the same L2 regularizer on all the parameters
% output is the return value from minFunc
%PMTKsupervisedModel mlpRegress
[model, output] = mlpRegressFitSchmidt(X, y, nHidden, lambda, options);
end