function [model, lambdaStar, kernelParamStar, mu, se] = linregKernelFitL2CV...
    (X, y, kernelParamRange, kernelType, lambdaRange, nfolds)
% L2 Linear Regression with a kernel basis expansion of the data, and
% lambda and Sigma chosen via cross validation.

if nargin < 3 || isempty(kernelParamRange)
    kernelParamRange = linspace(1, 10, 10);
end
if nargin < 4 || isempty(kernelType)
    kernelType = 'rbf';
end
if nargin < 5 || isempty(lambdaRange)
    lambdaRange = logspace(-1, 2, 20)';
end
if nargin < 6, nfolds = 5; end

fitFn = @(X, y, param)linregKernelFitL2(X, y, param(1), param(2), kernelType);
lossFn = @(y, yhat)mean((y-yhat).^2);
paramRange = crossProduct(lambdaRange, kernelParamRange);

[model, paramStar, mu, se] = fitCv...
    (paramRange, fitFn, @linregPredict, lossFn, X, y, nfolds);
lambdaStar = paramStar(1);
kernelParamStar = paramStar(2);
end