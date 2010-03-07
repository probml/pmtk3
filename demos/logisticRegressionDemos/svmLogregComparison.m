%% Compare kernalized L1 logistic regession to an svm. 
%PMTKslow
load crabs
%% SVM
Sigmas = logspace(-1, 0.5, 20);
Nfolds = 5;
lossFn = @(yhat, ytest)mean(yhat ~= ytest); 
[SVMmodel, SigmaStar, SVMmu, SVMse] = fitCv(Sigmas, @svmLightFit, @svmLightPredict, lossFn, Xtrain, ytrain,  Nfolds);
yhat = svmLightPredict(SVMmodel, Xtest);
svmNerrors = sum(yhat ~= ytest)
%% LR L2
% Cross validates over both lambda and 'rbf' Sigma
[LRL2model, lambdaStar, LRmu, LRse] = logregKernelFitL2CV(Xtrain, ytrain);
yhat = logregPredict(LRL2model, Xtest);
lrL2Nerrors = sum(yhat ~= ytest)
%% LR L1
lambdaL1 = 0.001; SigmaL1 = 8; % use logregKernelFitL1CV to cross validate both - slow
LRL1model = logregKernelFitL1(Xtrain, ytrain, lambdaL1, SigmaL1);
yhat = logregPredict(LRL1model, Xtest);
lrL1Nerrors = sum(yhat ~= ytest)