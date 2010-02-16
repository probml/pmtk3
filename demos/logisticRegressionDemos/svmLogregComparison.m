%% Compare kernalized L1 logistic regession to an svm. 
%#slow
load crabs
%% SVM
Sigmas = logspace(-1, 1, 20);
Nfolds = 5;
lossFn = @(yhat, ytest)mean(yhat ~= ytest); 
[SVMmodel, SigmaStar, SVMmu, SVMse] = fitCv(Sigmas, @svmFit, @svmPredict, lossFn, Xtrain, ytrain,  Nfolds);
yhat = svmPredict(SVMmodel, Xtest);
svmNerrors = sum(yhat ~= ytest)
%% LR
% Cross validates over both lambda and 'rbf' Sigma
[LRmodel, lambdaStar, LRmu, LRse] = logregKernelFitL2CV(Xtrain, ytrain);
yhat = logregPredict(LRmodel, Xtest);
lrNerrors = sum(yhat ~= ytest)
