function [model, sigmaStar, CVmu, CVse] = svmlightFitCV(X, y, sigmaRange, nfolds)
% Fit a model using svmlight selecting sigma via cross validation. 
if nargin < 3, sigmaRange = linspace(0.5, 15, 20); end
if nargin < 4, nfolds = 5; end
lossFn = @(y, yhat)mean(y~=yhat);
[model, sigmaStar, CVmu, CVse] = fitCv...
    (sigmaRange, @svmlightFit, @svmLightPredict, lossFn, X, y, nfolds);
end

%% SVM