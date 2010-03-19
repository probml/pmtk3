%% Simple Tests of the svmFit interface

load crabs
%%
model = svmFit(Xtrain, ytrain);
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
%%
tic
model = svmFit(Xtrain, ytrain, 'fitFn', @svmlightFit);
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
toc
%%
tic
model = svmFit(Xtrain, ytrain, 'fitFn', @svmQPclassifFit);
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
toc
%%
tic
model = svmFit(Xtrain, ytrain, 'fitFn', @svmlibFit);
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
toc
%%
model = svmFit(Xtrain, ytrain, 'C', logspace(-1,1,10));
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
%%
model = svmFit(Xtrain, ytrain, 'kernel', @kernelPoly, 'kernelParam', 3)
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
%%
model = svmFit(Xtrain, ytrain, 'C', logspace(-1, 1, 10), 'kernel', @kernelPoly, 'kernelParam', 3)
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
%%
model = svmFit(Xtrain, ytrain, 'kernel', 'linear');
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
%% REGRESSION
load prostate
%%
model = svmFit(Xtrain, ytrain);
yhat = svmPredict(model, Xtest);
mse = mean((yhat - ytest).^2)
%%
model = svmFit(Xtrain, ytrain, 'fitFn', @svmQPregFit)
yhat = svmPredict(model, Xtest);
mse = mean((yhat - ytest).^2)
%%
model = svmFit(Xtrain, ytrain, 'kernel', 'rbf', 'kernelParam', [0.1, 0.5, 1, 5], 'C', logspace(-1,1,10))
yhat = svmPredict(model, Xtest);
mse = mean((yhat - ytest).^2)
%%
model = svmFit(Xtrain, ytrain, 'kernel', 'poly', 'kernelParam', 1:10, 'C', logspace(-2,2,30))
yhat = svmPredict(model, Xtest);
mse = mean((yhat - ytest).^2)
%%
model = svmFit(Xtrain, ytrain, 'kernel', 'linear', 'C', logspace(-2,2,100));
yhat = svmPredict(model, Xtest);
error = mean((yhat - ytest).^2)
%% MULTICLASS
load soy
setSeed(0);
[X, Y] = shuffleRows(X, Y);
Xtrain = X(1:250, :); ytrain = Y(1:250); 
Xtest = X(251:end, :); ytest = Y(251:end);
%%
model = svmFit(Xtrain, ytrain);
yhat = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
