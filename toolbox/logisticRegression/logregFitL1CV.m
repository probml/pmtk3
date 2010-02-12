function [model, lambdaStar, mu, se] = logregFitL1CV(X, y, lambdaRange, includeOffset, nfolds)
    
    if nargin < 3, 
        lambdaRange = [0, logspace(-2.5, 0, 5), logspace(0.1, 1.5, 10), logspace(1.6, 2.5, 4)];
    end
    if nargin < 4, includeOffset = true; end
    if nargin < 5, nfolds = 5; end
    fitFn = @(X, y, lambda)logregFitL1(X, y, lambda, includeOffset);
    lossFn = @(yhat, ytest)mean(yhat ~= ytest); 
    
    [model, lambdaStar, mu, se] = ...
        fitCv(lambdaRange, fitFn, @logregPredict, lossFn, X, y, nfolds);
end