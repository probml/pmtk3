function [model, lambdaStar, mu, se] = linregFitL1CV (X, y, lambdaRange, standardizeX, nfolds)
% L1 Linear Regression with lambda chosen via cross validation.
if nargin < 3, lambdaRange = linspace(0, lassoMaxLambda(X, center(y)), 20)'; end
if nargin < 4, standardizeX = true;  end
if nargin < 5, nfolds = 5; end

if standardizeX
    [X, model.Xmu] = center(X);
    [X, model.Xstnd] = mkUnitVariance(X);
end

fitFn = @(X, y, lambda)linregFitL1(X, y, lambda, 'lars', false);
lossFn = @(y, yhat)mean((y-yhat).^2);

[model, lambdaStar, mu, se] = fitCv...
   (lambdaRange, fitFn, @linregPredict, lossFn, X, y, nfolds);

end