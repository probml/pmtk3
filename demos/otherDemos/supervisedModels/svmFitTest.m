%% Simple Tests of the svmFit interface
% PMTKslow
% PMTKneedsOptimToolbox quadprog
%% First we check that the 3 implementations give the same
% results on a simple binary dataset

% This file is from pmtk3.googlecode.com

requireOptimToolbox
loadData('crabs'); 

model = svmFit(Xtrain, ytrain);
yhat  = svmPredict(model, Xtest);
errorRateGen = mean(yhat ~= ytest);

if ispc % svmlight only works on windows
    tic
    model = svmFit(Xtrain, ytrain, 'fitFn', @svmlightFit);
    yhat  = svmPredict(model, Xtest);
    errorRateSvmLight = mean(yhat ~= ytest);
    timeSvmLight = toc;
end

tic
model = svmFit(Xtrain, ytrain, 'fitFn', @svmQPclassifFit);
yhat  = svmPredict(model, Xtest);
errorRateQp = mean(yhat ~= ytest);
timeQp = toc;

tic
model = svmFit(Xtrain, ytrain, 'fitFn', @svmlibFit);
yhat  = svmPredict(model, Xtest);
errorRateSvmLib = mean(yhat ~= ytest);
timeSvmLib=toc;

fprintf('method \t error \t time \n');
if ispc
    fprintf('svmLight \t %5.3f \t %5.3f\n', errorRateSvmLight, timeSvmLight);
end
fprintf('svmQp \t %5.3f \t %5.3f\n', errorRateQp, timeQp);
fprintf('svmLib \t %5.3f \t %5.3f\n', errorRateSvmLib, timeSvmLib);



%% Example of how to do CV
model = svmFit(Xtrain, ytrain, 'C', logspace(-1,1,10));
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
%% Example of how to specify the kernel
model = svmFit(Xtrain, ytrain, 'kernel', @kernelPoly, 'kernelParam', 3);
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)

model = svmFit(Xtrain, ytrain, 'kernel', 'linear');
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)


%% CV and kernels
model = svmFit(Xtrain, ytrain, 'C', logspace(-1, 1, 10), 'kernel', @kernelPoly, 'kernelParam', 3);
yhat  = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)


%% REGRESSION
loadData('prostate');
%%
model = svmFit(Xtrain, ytrain);
yhat = svmPredict(model, Xtest);
mse = mean((yhat - ytest).^2)
%%
model = svmFit(Xtrain, ytrain, 'fitFn', @svmQPregFit);
yhat = svmPredict(model, Xtest);
mse = mean((yhat - ytest).^2)
%%
model = svmFit(Xtrain, ytrain, 'kernel', 'rbf', 'kernelParam', [0.1, 0.5, 1, 5], 'C', logspace(-1,1,10));
yhat = svmPredict(model, Xtest);
mse = mean((yhat - ytest).^2)
%%
model = svmFit(Xtrain, ytrain, 'kernel', 'poly', 'kernelParam', 1:10, 'C', logspace(-2,2,30));
yhat = svmPredict(model, Xtest);
mse = mean((yhat - ytest).^2)
%%
model = svmFit(Xtrain, ytrain, 'kernel', 'linear', 'C', logspace(-2,2,100));
yhat = svmPredict(model, Xtest);
error = mean((yhat - ytest).^2)
%% MULTICLASS
loadData('soy')
setSeed(0);
[X, Y] = shuffleRows(X, Y);
Xtrain = X(1:250, :); ytrain = Y(1:250); 
Xtest = X(251:end, :); ytest = Y(251:end);
%%
model = svmFit(Xtrain, ytrain);
yhat = svmPredict(model, Xtest);
errorRate = mean(yhat ~= ytest)
