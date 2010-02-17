function [model, Kstar, mu, se] = fitCv(Ks, fitFn, predictFn, lossFn, X, y,  Nfolds, useSErule)
% Fit a set of models of different complexity and use cross validation to pick the best
%
% Inputs:
% Ks is a matrix of tuning parameters,
% each row corresponds to a different model 
%  eg Ks = [lambda1(1) lambda2(1); ...
%           lambda1(N) lambda2(N)]
%  You can use the crossProduct function to create this if necessary
% model = fitFn(Xtrain, ytrain, K), K = vector of tuning parameters
% yhat = predictFn(model, Xtest)
% L = lossFn(yhat, ytest), should return a vector of errors
% X is N*D design matrix
% y is N*1
% Nfolds is number of CV folds; set to N to get LOOCV
% useSErule: if true,  pick simplest model within 1 standard error
%  of best; we assume models (rows of Ks) are ordered from simplest to most
%  complex!
%
% Outputs
% model  - best model
% Kstar - best tuning parameter
% mu(i) - mean loss for Ks(i)
% se(i) - standard error for mu(i)

if nargin < 8, useSErule = false; end
% if params is 1 row vector, it is a probbaly a set of
% single tuning params
if isvector(Ks), Ks = Ks(:); end
NK = size(Ks,1);
mu = zeros(1,NK);
se = zeros(1,NK);
for ki=1:NK
  K = Ks(ki,:);
  [mu(ki), se(ki)] =  cvEstimate(@(X,y) fitFn(X,y,K), predictFn, lossFn, X, y,  Nfolds);
end    
if useSErule
  kstar = oneStdErrorRule(mu, se);
else
  kstar = argmin(mu);
end
Kstar = Ks(kstar,:);
model = fitFn(X, y, Kstar);
