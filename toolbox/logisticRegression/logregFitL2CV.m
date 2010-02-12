function [model, lambdaStar, mu, se] = logregFitL2CV(X, y, lambdaRange, includeOffset, nfolds)
    
    switch nargin
        case 2, args = {};
        case 3, args = {lambdaRange};
        case 4, args = {lambdaRange, includeOffset};
        case 5, args = {lambdaRange, includeOffset, nfolds};    
    end
    [model, lambdaStar, mu, se] = logregFitCV(X, y, @penalizedL2, args{:});
end