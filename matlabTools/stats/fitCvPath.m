function [model, bestParam, mu, se] = ...
    fitCvPath(fitPathFn, predictPathFn, lossFn, X, y, extractPathFn, varargin)
%% Fit regularization path and use cross validation to pick the best point
%
% Inputs:
% models = fitPathFn(Xtrain, ytrain)
%  This should return models.lambdas
% yhat = predictFn(models, Xtest): yhat(i,j) is prediction
%  for Xtest(i,:) using j'th reg value
% L = lossFn(yhat, ytest), should return a matrix of losses
% X is N*D design matrix
% y is N*1
% Nfolds is number of CV folds; set to N to get LOOCV
% useSErule: if true,  pick simplest model within 1 standard error
%  of best; we assume models (rows of params) are ordered from simplest to most
%  complex.
%
% Outputs
% model  - best model
% bestParam -
% mu(i) - mean loss for params(i,:)
% se(i) - standard error for mu(i,:)
%%

% This file is from pmtk3.googlecode.com


%PMTKbroken % always seems to pick the most complex model...

[Nfolds, useSErule, testFolds, randomizeOrder] = ...
    process_options(varargin , ...
    'Nfolds'         , 5     , ...
    'useSErule'      , false , ...
    'testFolds'      , []    , ...
    'randomizeOrder' , false );

N = size(X,1);
if isempty(testFolds)
  [trainfolds, testfolds] = Kfold(N, Nfolds, randomizeOrder);
else
  % explicitly specify the test folds
  [nTest nFolds] = size(testFolds);
  testfolds = mat2cell(testFolds, nTest, ones(nFolds,1));
  trainfolds = cellfun(@(t)setdiff(1:N,t), testfolds, 'UniformOutput', false);
end

% Fit on all data
modelsAllData = fitPathFn(X, y);
NL = length(modelsAllData.lambdas);
%loss = zeros(N,NL);
yhat = zeros(N,NL);

for f=1:Nfolds
   Xtrain = X(trainfolds{f},:); Xtest = X(testfolds{f},:);
   ytrain = y(trainfolds{f}); ytest = y(testfolds{f});
   ytestRep = repmat(ytest(:), 1, NL);
   models = fitPathFn(Xtrain, ytrain);
   yhat(testfolds{f},:) = predictPathFn(models, Xtest);
   %loss(testfolds{f},:) = lossFn(yhat, ytestRep);
end
loss = lossFn(yhat, repmat(y, 1, NL));
mu = mean(loss,1);
se = std(loss,1,1)/sqrt(N);

if useSErule
    bestNdx = oneStdErrorRule(mu, se);
else
    bestNdx = argmin(mu);
end
bestParam = bestNdx;
model = extractPathFn(modelsAllData, bestNdx);

end
