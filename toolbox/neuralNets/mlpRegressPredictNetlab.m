function [mu, sigma2] = mlpRegressPredictNetlab(model, X)
% Prediction for multi-layer perceptron for  regression
% mu(i,:) is the posteiror mean
% sigma2(i,:) is the posterior variance (plugin approximation)

[mu] = mlpfwd(model.net, X);
N  = size(X,1);
if nargout >= 2
  sigma2 = repmat(1/model.net.beta, N, 1);
end

end