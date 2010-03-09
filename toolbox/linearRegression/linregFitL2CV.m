function [model, lambdaStar, mu, se] = linregFitL2CV (X, y, lambdaRange, standardizeX, nfolds)
% L2 Linear Regression with lambda chosen via cross validation.
if nargin < 3, lambdaRange = logspace(-1, 2, 20)'; end
if nargin < 4, standardizeX = true;  end
if nargin < 5, nfolds = 5; end

if standardizeX
    [X, model.Xmu] = center(X);
    [X, model.Xstnd] = mkUnitVariance(X);
end

fitFn = @(X, y, lambda)linregFitL2(X, y, lambda, 'QR', false);
lossFn = @(y, yhat)mean((y-yhat).^2);

[model, lambdaStar, mu, se] = fitCv...
   (lambdaRange, fitFn, @linregPredict, lossFn, X, y, nfolds);

end