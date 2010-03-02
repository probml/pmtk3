function [model, bestNdx, mu, se] = fitCv(params, fitFn, predictFn, lossFn, X, y,  Nfolds, useSErule)
% Fit a set of models of different complexity and use cross validation to pick the best
%
% Inputs:
% params is a matrix where each row corresponds to a different tuning parameter 
%  eg models = [lambda1(1) lambda2(1); ...
%               lambda1(N) lambda2(N)]
%  You can use the crossProduct function to create this if necessary
% model = fitFn(Xtrain, ytrain, param), param = vector of tuning parameters
% yhat = predictFn(model, Xtest)
% L = lossFn(yhat, ytest), should return a column vector of errors
% X is N*D design matrix
% y is N*1
% Nfolds is number of CV folds; set to N to get LOOCV
% useSErule: if true,  pick simplest model within 1 standard error
%  of best; we assume models (rows of params) are ordered from simplest to most
%  complex.
%
% Outputs
% model  - best model
% bestNdx - index of best model
% mu(i) - mean loss for params(i,:)
% se(i) - standard error for mu(i,:)

if nargin < 8, useSErule = false; end
% if params is 1 row vector, it is a probbaly a set of
% single tuning params
if size(params,1)==1
  %warning('fitCV expects each *row* of Ks to containg tuning params')
  params = params(:);
end
NM = size(params,1);
mu = zeros(1,NM);
se = zeros(1,NM);
for m=1:NM
  param = params(m,:);
  [mu(m), se(m)] =  cvEstimate(@(X,y) fitFn(X,y,param), predictFn, lossFn, X, y,  Nfolds);
end    
if useSErule
  bestNdx = oneStdErrorRule(mu, se);
else
  bestNdx = argmin(mu);
end
bestParam = params(bestNdx,:);
model = fitFn(X, y, bestParam);
