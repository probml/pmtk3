function [model, lambdaStar, mu, se] = logregFitL1CV(X, y, lambdaRange, includeOffset, nfolds)
    
    switch nargin
        case 2, args = {};
        case 3, args = {lambdaRange};
        case 4, args = {lambdaRange, includeOffset};
        case 5, args = {lambdaRange, includeOffset, nfolds};    
    end
    [model, lambdaStar, mu, se] = logregFitCV(X, y, @penalizedL1, args{:});
end