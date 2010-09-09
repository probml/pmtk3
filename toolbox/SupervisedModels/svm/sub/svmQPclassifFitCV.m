function [model, sigmaStar, CVmu, CVse] = svmQPclassifFitCV(X, y, Crange, nfolds)
% Fit a model using svmlight selecting sigma via cross validation. 
% PMTKneedsOptimToolbox
%%

% This file is from pmtk3.googlecode.com

if nargin < 3, Crange = 1./logspace(2, -1, 20); end
if nargin < 4, nfolds = 5; end
lossFn = @(y, yhat)mean(y~=yhat);
kernFn = @(X1, X2, C)kernelBasis(X1, X2, 'rbf', C);
fitFn = @(X, y, C)svmQPclassifFit(X, y, kernFn, C);
[model, sigmaStar, CVmu, CVse] = fitCv...
    (Crange, fitFn, @svmQPclassifPredict, lossFn, X, y, nfolds);
end

