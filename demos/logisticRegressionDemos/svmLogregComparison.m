%% Compare kernalized L1 logistic regession to an svm. 
%PMTKslow
load crabs
%% SVM
Sigmas = logspace(-1, 0.5, 20);
Nfolds = 5;
C = 1; 
lossFn = @(yhat, ytest)mean(yhat ~= ytest); 
fitFn = @(X, y, Sigma)svmlightFit(X, y, C, Sigma); 
[SVMmodel, SigmaStar, SVMmu, SVMse] = fitCv(Sigmas, fitFn, @svmlightPredict, lossFn, Xtrain, ytrain,  Nfolds);
yhat = svmlightPredict(SVMmodel, Xtest);
svmNerrors = sum(yhat ~= ytest)
%% LR L2
% Cross validates over both lambda and 'rbf' Sigma
[LRL2model, lambdaStar, LRmu, LRse] = logregFit(Xtrain, ytrain,...
    'kernelFn', @rbfKernel, 'lambda', logspace(-7, -3, 20), 'kernelParam', 7:0.5:10);
yhat = logregPredict(LRL2model, Xtest);
lrL2Nerrors = sum(yhat ~= ytest)
%% LR L1
lambdaL1 = 1e-7; SigmaL1 = 8; % see logregKernelCrabsDemo for cross validation
LRL1model = logregFit(Xtrain, ytrain, 'lambda', lambdaL1, ...
    'kernelFn', @rbfKernel, 'kernelParam', SigmaL1);
yhat = logregPredict(LRL1model, Xtest);
lrL1Nerrors = sum(yhat ~= ytest)