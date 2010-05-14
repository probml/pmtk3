%% Compare kernalized L1 logistic regession to an svm. 
%
%%
load crabs
%% SVM
gammas = logspace(-2, 2, 30);
Cvals  = logspace(-1, 3.5, 30);
SVMmodel = svmFit(Xtrain, ytrain, 'kernel', 'rbf', ...
    'C', Cvals, 'kernelParam', gammas);
yhat = svmPredict(SVMmodel, Xtest);
svmNerrors = sum(yhat ~= ytest) %0
%% LR L1
lambdaL1 = 3e-7; SigmaL1 = 8.5; % see logregKernelCrabsDemo for cross validation
args.lambda = lambdaL1;
args.preproc.kernelFn = @(X1, X2)kernelRbfSigma(X1, X2, SigmaL1);
args.regType = 'L1';
LRL1model = logregFit(Xtrain, ytrain, args);
yhat = logregPredict(LRL1model, Xtest);
lrL1Nerrors = sum(yhat ~= ytest)
%% LR L2 (no kernel)
lambdas = logspace(-5,0,50);
[LRL2model, lambdas, LRmu, LRse] = logregFit(Xtrain, ytrain,...
    'lambda', lambdas, 'regType', 'L2');
yhat = logregPredict(LRL2model, Xtest);
lrL2Nerrors = sum(yhat ~= ytest)
