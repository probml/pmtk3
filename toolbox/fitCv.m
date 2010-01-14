function [model, Kstar, mu, se] = fitCv(Ks, fitFn, predictFn, lossFn, X, y,  Nfolds)
% Fit a set of models of different complexity and use cross validation to
% pick the best
%
% Inputs:
% Ks is a vector of tuning parameters (e.g., lambdas for ridge regression)
%    *** We assume models are ordered from least complex to most complex
% model = fitFn(Xtrain, ytrain, K)
% yhat = predictFn(model, Xtest)
% L = lossFn(yhat, ytest), should return a vector of errors
% X is N*D design matrix
% y is N*1
% Nfolds is number of CV folds
%
% Outputs
% model  - best model
% Kstar - best tuning parameter
% mu(i) - mean loss for Ks(i)
% se(i) - standard error for mu(i)

NK = length(Ks);
mu = zeros(1,NK);
se = zeros(1,NK);
for ki=1:NK
  K = Ks(ki);
  [mu(ki), se(ki)] =  cvEstimate(@(X,y) fitFn(X,y,K), predictFn, lossFn,...
    X, y,  Nfolds);
end    
kstar = oneStdErrorRule(mu, se);
Kstar = Ks(kstar);
model = fitFn(X, y, Kstar);
