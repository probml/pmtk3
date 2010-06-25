%% Fit a rbf kernel binary logistic regression model to the crabs data 
% PMTKslow
% see svmCrabsDemo
%% Load data
loadData('crabs');
%%
%% Here we cross validate over both lambda and Sigma
lambda     = logspace(-7, -4, 20); 
Sigma      = 8:0.5:10;
paramRange = crossProduct(lambda, Sigma); 
%% Construct fit function
% plotCv expects a function of three variables, X, y, and param, where
% param is a 1x2 vector with lambda = param(1) and Sigma = param(2). Notice
% that a call to fitFn of the form fitFn(X, y, [lambda, Sigma]) will 
% construct the kernel function @(X1, X2)kernelRbfSigma(X1, X2, Sigma) 'on
% the fly', i.e. anew each time with a potentially different value of
% Sigma. 
fitFn = @(X, y, param)...
    logregFit(X, y, 'lambda', param(1), 'regType', 'L1', 'preproc', ...
    struct('kernelFn', @(X1, X2)kernelRbfSigma(X1, X2, param(2))));
%%
predictFn = @logregPredict;
lossFn = @(ytest, yhat)mean(yhat ~= ytest);
nfolds = 5; 
useSErule = true;
plotCv = true; 
[LRmodel, lambdaStar, LRmu, LRse] = ...
    fitCv(paramRange, fitFn, predictFn, lossFn, Xtrain, ytrain, nfolds, ...
    'useSErule', useSErule, 'doPlot', plotCv);

set(gca, 'xscale', 'log')
yhat = logregPredict(LRmodel, Xtest);
lrL1Nerrors = sum(yhat ~= ytest) 




