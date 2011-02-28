%% Compare kernalized L1 logistic regession to an svm. 
%
%%

% This file is from pmtk3.googlecode.com

if ~svmInstalled
    fprintf('cannot run %s without svmFit; skipping\n', mfilename());
    return;
end
loadData('crabs');
%% SVM
gammas = logspace(-2, 2, 30);
Cvals  = logspace(-1, 3.5, 30);
SVMmodel = svmFit(Xtrain, ytrain, 'kernel', 'rbf', ...
    'C', Cvals, 'kernelParam', gammas);
yhat = svmPredict(SVMmodel, Xtest);
svmNerrors = sum(yhat ~= ytest) %0
%% LR L1
lambdaL1 = 1e-3; SigmaL1 = 0.5;
args.lambda = lambdaL1;
args.preproc.kernelFn = @(X1, X2)kernelRbfSigma(X1, X2, SigmaL1);
args.preproc.rescaleX = true;
args.regType = 'L1';
LRL1model = logregFit(Xtrain, ytrain, args);
yhat = logregPredict(LRL1model, Xtest);
lrL1Nerrors = sum(yhat ~= ytest)
%% LR L2 (no kernel)
lambdas = logspace(-5,0,50);
LRL2model = fitCv(lambdas, @(X, y, l)logregFit(X, y, 'lambda', l, 'regType', 'L2'), ...
    @logregPredict, @zeroOneLossFn, Xtrain, ytrain); 


yhat = logregPredict(LRL2model, Xtest);
lrL2Nerrors = sum(yhat ~= ytest)
