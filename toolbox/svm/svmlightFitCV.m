function [model, gammaStar, CVmu, CVse] = svmlightFitCV(X, y, C, gammaRange, nfolds)
% Fit a model using svmlight selecting gamma via cross validation. 
if nargin < 3, gammaRange = linspace(0.5, 15, 20); end
if nargin < 4, nfolds = 5; end
lossFn = @(y, yhat)mean(y~=yhat);
fitfn = @(X,y,gamma)svmlightFit(X,y,C,gamma); 
[model, gammaStar, CVmu, CVse] = fitCv...
    (gammaRange, fitfn, @svmlightPredict, lossFn, X, y, nfolds);
end

