function model = logregFitL1(X, y, lambda, includeOffset)
% Fit a binary or multiclass logistic regression model with an L1 
% regularizer. 
% X(i, :)      - is the ith case
% y            - the labels - these will be automatically transformed into 
%                the right spcae.
% lambda       - optional L1 regularizer, (default = 0)
% inclueOffset - if true, (default) a column of ones is added to X
    if nargin < 3, lambda        = 0;    end
    if nargin < 4, includeOffset = true; end
    model = logregFitCore(X, y, lambda, includeOffset, @penalizedL1);
end