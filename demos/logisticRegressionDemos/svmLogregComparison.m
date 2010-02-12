%% Compare kernalized L1 logistic regession to an svm. 
%#slow
load crabs
setSeed(0);
perm = randperm(size(Xtrain, 1));
Xtrain = Xtrain(perm, :);
ytrain = ytrain(perm);

%% SVM
Sigmas = logspace(-1, 1, 20);
Nfolds = 5;
lossFn = @(yhat, ytest)mean(yhat ~= ytest); 
[SVMmodel, SigmaStar, SVMmu, SVMse] = fitCv(Sigmas, @svmFit, @svmPredict, lossFn, Xtrain, ytrain,  Nfolds);
yhat = svmPredict(SVMmodel, Xtest);
svmNerrors = sum(yhat ~= ytest)
%% LR
sigmaLR = 1;
lambdas = logspace(-2, 1, 10);
[LRmodel, lambdaStar, LRmu, LRse] = fitCv(lambdas, @logregL1Fit, @logregPredict, lossFn, Xtrain, ytrain, Nfolds);
yhat = logregPredict(LRmodel, Xtest);
lrNerrors = sum(yhat ~= ytest)


fitFn = @(X, y, lambda)logregL1Fit(rbfKernel(X, Xtrain , sigmaLR), y, lambda, addOnes);
predictFn = @(m, X) logregPredict(m, rbfKernel(X, Xtrain, sigmaLR)); 
[LRmodel, lambdaStar, LRmu, LRse] = fitCv(lambdas, fitFn, predictFn, lossFn, Xtrain, ytrain, Nfolds);
yhat = logregPredict(LRmodel, rbfKernel(Xtest, Xtrain, sigmaLR));
lrNerrors = sum(yhat ~= ytest)