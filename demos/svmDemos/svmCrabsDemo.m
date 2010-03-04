%% Run svm light on a binary dataset
%PMTKslow
load crabs
%% SVM
Sigmas = logspace(-1, 0.5, 20);
Nfolds = 5;
lossFn = @(yhat, ytest)mean(yhat ~= ytest); 
[SVMmodel, SigmaStar, SVMmu, SVMse] = fitCv(Sigmas, @svmFit, @svmPredict, lossFn, Xtrain, ytrain,  Nfolds);
yhat = svmPredict(SVMmodel, Xtest);
svmNerrors = sum(yhat ~= ytest) % 12
