function [mu, sigma2] = mlpRegressPredict(model, X)
% Multi-layer perceptron for regression
[mu, sigma2] = mlpRegressPredictSchmidt(model, X);

end