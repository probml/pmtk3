function model = mlpClassifFit(X, y, nHidden, lambda, options)
% Multi-layer perceptron for BINARY regression; fit using minFunc
% nHidden can be a vector of integers if there are multiple laters
% We currenly assume the same L2 regularizer on all the parameters
%PMTKsupervisedModel mlpClassif
model = mlpClassifFitSchmidt(X, y, nHidden, lambda, options);
end