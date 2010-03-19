%% fit a rbf kernel binary logistic regression model to the crabs data 
load crabs
% Cross validates over both lambda and 'rbf' Sigma
[LRL2model, lambdaStar, LRmu, LRse] = logregFit(Xtrain, ytrain,...
    'kernelFn', @kernelRbfSigma, 'lambda',logspace(-7,-4,20), 'kernelParam', 8:0.5:10, 'doPlot', true, 'regType', 'L1');
set(gca, 'xscale', 'log')
yhat = logregPredict(LRL2model, Xtest);
lrL1Nerrors = sum(yhat ~= ytest) %1
%(see svmCrabsDemo)



