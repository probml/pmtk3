function [model] = logregFitBayes(X, y, varargin)
% Fit *binary* logistic regression using Bayesian inference
% X is n*d, y is d*1, y(i) = 0 or 1
% Do not add a column of 1s
%
% By default we use a N(0,(1/lambda) I) prior
% and Lapalce approximation
% We set lambda to be small to give a weak prior

model = logregFitBayesLaplace(X, y, varargin{:});

end
