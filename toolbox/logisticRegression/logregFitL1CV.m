function [model, lambdaStar, mu, se] = logregFitL1CV...
        (X, y, lambdaRange, includeOffset, nfolds)
% Fit a binary or multiclass logistic regression model using cross 
% validation to select the L1 regularizer.
% X(i, :)       - is the ith case
% y             - the labels - these will be automatically transformed into
%                 the right spcae.
% lambdaRange   - optional range to cross validate over
% inclueOffset  - if true, (default) a column of ones is added to X
% nfolds       - the number of cross validation folds, (defualt = 5)    
    switch nargin
        case 2, args = {};
        case 3, args = {lambdaRange};
        case 4, args = {lambdaRange, includeOffset};
        case 5, args = {lambdaRange, includeOffset, nfolds};    
    end
    [model, lambdaStar, mu, se] = logregFitCV(X, y, @penalizedL1, args{:});
end