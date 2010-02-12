function [model, lambdaStar, mu, se] = logregFitL1CV(X, y, lambdaRange, includeOffset, nfolds)
    
    if nargin < 3, 
        lambdaRange = [0, logspace(-2.5, 0, 5), logspace(0.1, 1.5, 10), logspace(1.6, 2.5, 4)];
    end
    
    Nclasses = numel(unique(y)); 
    if Nclasses < 3
       [y, support] = setSupport(y, [-1, 1]); 
    else
       [y, support] = setSupport(y, 1:Nclasses); 
    end
    
    
    if nargin < 4, includeOffset = true; end
    if nargin < 5, nfolds = 5; end
    fitFn = @(X, y, lambda)logregFitCore(X, y, lambda, includeOffset, @penalizedL1, Nclasses);
    lossFn = @(yhat, ytest)mean(yhat ~= ytest); 
    
    [model, lambdaStar, mu, se] = ...
        fitCv(lambdaRange, fitFn, @logregPredict, lossFn, X, y, nfolds);
    model.ySupport = support; 
end