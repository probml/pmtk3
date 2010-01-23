function [mu, sigma2] = mlpRegressPredictSchmidt(model, X)
% Multi-layer perceptron for regression

[N,D] = size(X);
X = [ones(N,1) X];
mu = MLPregressionPredict(model.w, X, model.nHidden);
N = length(mu);
if nargout >= 2
  sigma2 = repmat(model.sigma2, N, 1);
  % predictive variance is constant since we are using a plug-in approx
end