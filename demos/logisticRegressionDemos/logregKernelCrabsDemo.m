%% fit a rbf kernel binary logistic regression model to the crabs data 
load crabs
% Cross validates over both lambda and 'rbf' Sigma
[LRL2model, lambdaStar, LRmu, LRse] = logregKernelFitL2CV(Xtrain, ytrain);
yhat = logregPredict(LRL2model, Xtest);
lrL2Nerrors = sum(yhat ~= ytest) %0
% This error rate is better than an SVM (see svmCrabsDemo)



