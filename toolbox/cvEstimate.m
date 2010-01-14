function [mu, se] = cvEstimate(fitFn, predictFn, lossFn, X, y,  Nfolds)
% Cross validation estimate of expected loss
% model = fitFn(Xtrain, ytrain)
% yhat = predictFn(model, Xtest)
% L = lossFn(yhat, ytest), should return a vector of errors
% X is N*D design matrix
% y is N*1
% Nfolds is number of CV folds
% mu is expected error
% se is standard error

N = size(X,1);
randomizeOrder = true;
[trainfolds, testfolds] = Kfold(N, Nfolds, randomizeOrder);
loss = zeros(1,N);
for f=1:length(trainfolds)
   Xtrain = X(trainfolds{f},:); Xtest = X(testfolds{f},:);
   ytrain = y(trainfolds{f}); ytest = y(testfolds{f});
   model = fitFn(Xtrain, ytrain);
   yhat = predictFn(model, Xtest);
   loss(testfolds{f}) = lossFn(yhat, ytest);
end 
mu = mean(loss);
se = std(loss)/sqrt(N);


