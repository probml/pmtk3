function [model, lambdaStar, mu, se] = logregFitCV...
        (X, y, regularizerFn, lambdaRange, includeOffset, nfolds)
% Fit a binary or multiclass logistic regression model using cross 
% validation to select the regularizer - see logregFitL1CV and 
% logregFitL2CV. 
%
% X(i, :)       - is the ith case
% y             - the labels - these will be automatically transformed into
%                 the right spcae.
% regularizerFn - @penalizedL1, or @penalizedL2 (default=L2)
% lambdaRange   - values to try or [] (default) for auto generated
% inclueOffset  - if true, (default) a column of ones is added to X
% nfolds       - the number of cross validation folds, (defualt = 5)
    if nargin < 3 || isempty(regularizerFn),
      regularizerFn = @penalizedL2;
    end
    if nargin < 4 || isempty(lambdaRange), 
        lambdaRange = [0, logspace(-2.5, 0  , 5  ), ...
                          logspace( 0.1, 1.5, 10 ), ...
                          logspace( 1.6, 2.5, 4) ];
    end
    Nclasses = numel(unique(y)); 
    if Nclasses < 3,   newSupport = [-1, 1];
    else               newSupport = 1:Nclasses; 
    end
    [y, support] = setSupport(y, newSupport); 
    if nargin < 5, includeOffset = true; end
    if nargin < 6, nfolds = 5; end
    nfolds = min(size(X, 1), nfolds); 
    fitFn = @(X, y, lambda)...
       logregFitCore(X, y, lambda, includeOffset, regularizerFn, Nclasses);
    lossFn = @(yhat, ytest)mean(yhat ~= ytest); 
    [model, lambdaStar, mu, se] = ...
        fitCv(lambdaRange, fitFn, @logregPredict, lossFn, X, y, nfolds);
    model.ySupport = support; 
end