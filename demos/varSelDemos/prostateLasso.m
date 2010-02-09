%% L1 linear regression with cross validation on the prostate data set 
% Reproduce fig 3.6 on p58 of "Elements of statistical learning" 
load prostate
includeOffset = true;
fitFn     = @(X, y, lambda)linregL1Fit(X, y, lambda, includeOffset);
predictFn = @linregPredict;
lossFn    = @(yhat, ytest)mean((yhat - ytest).^2);
lambdas = [logspace(2, 0, 30) 0];
nfolds = 10; 
%%
[model, lambdaStar, mu, se] = ...
    fitCv(lambdas, fitFn, predictFn, lossFn, Xtrain, ytrain, nfolds);
%%
useLogScale = true; 
h = plotCVcurve(lambdas(end:-1:1), mu, se, lambdaStar, useLogScale); 
xlabel('lambda value');
%%
yhat = linregPredict(model, Xtest); 
title(sprintf('lasso, mseTest = %5.3f', lossFn(yhat, ytest)));

