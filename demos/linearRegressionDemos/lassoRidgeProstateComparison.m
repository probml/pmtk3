 %% Compare L1 vs L2 linear regression on the prostate data set
 
load prostate
includeOffset = true;
fitFns        = {@(X, y, lambda)linregL1Fit(X, y, lambda, includeOffset) 
                 @(X, y, lambda)linregL2Fit(X, y, lambda, includeOffset)};
predictFn     =  @linregPredict;
lossFn        =  @(yhat, ytest)mean((yhat - ytest).^2);
lambdas       = [logspace(2, 0, 30) 0];
figureNames   = {'prostateLassoCV', 'prostateRidgeCV'};
titlePrefixes = {'lasso', 'ridge'};
nfolds = 10;
useLogScale = true; 

for i=1:numel(fitFns);
    [model, lambdaStar, mu, se] = ...
        fitCv(lambdas, fitFns{i}, predictFn, lossFn, Xtrain, ytrain, nfolds);
    figure;
    h = plotCVcurve(lambdas(end:-1:1), mu, se, lambdaStar, useLogScale); 
    xlabel('lambda value');
    yhat = linregPredict(model, Xtest); 
    title(sprintf('%s, mseTest = %5.3f', titlePrefixes{i}, lossFn(yhat, ytest)));
    printPmtkFigure(figureNames{i});
end