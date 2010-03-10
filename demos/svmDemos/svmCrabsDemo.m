%% Run svm light on a binary dataset
%PMTKslow
load crabs
%% SVM
gammas = logspace(-1, 0.5, 20);
Nfolds = 5;
lossFn = @(yhat, ytest)mean(yhat ~= ytest); 
fitfn = @(X,y,gamma)svmlightFit(X, y, [], gamma); % [] to use default C value
[SVMmodel, SigmaStar, SVMmu, SVMse] = fitCv(gammas, fitfn, @svmlightPredict, lossFn, Xtrain, ytrain,  Nfolds);
yhat = svmlightPredict(SVMmodel, Xtest);
svmNerrors = sum(yhat ~= ytest) % 12

