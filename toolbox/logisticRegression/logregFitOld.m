function model = logregFit(X, y, lambda, includeOffset)
% Simple binary or multiclass logistic regression with optional L2
% penalization. 
%
% X(i, :)      - is the ith case
% y            - the labels - these will be automatically transformed into the
%                right spcae.
% lambda       - optional L2 regularizer, (default = 0)
% inclueOffset - if true, (default) a column of ones is added to X
%
    switch nargin
        case 2, args = {};
        case 3, args = {lambda};
        case 4, args = {lambda, includeOffset};
    end
    model = logregFitL2(X, y, args{:});
end