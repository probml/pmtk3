%% Simple Test of linregFit()

load servo
lossFn = @(y, yhat)mean((y-yhat).^2);
%%
model = linregFit(Xtrain, ytrain, 'lambda', 0, 'standardizeX', false); %ols
yhat = linregPredict(model, Xtest);
mse = lossFn(yhat, ytest)
%%
[ytrain, ybar] = center(ytrain);
w = Xtrain \ ytrain;
w0  = ybar - mean(Xtrain)*w;
assert(isequal(w, model.w));
assert(isequal(w0, model.w0));

%% CV over lambda
[model, bestLambda] = linregFit(Xtrain, ytrain, 'doPlot', true);
yhat = linregPredict(model, Xtest);
mse = lossFn(yhat, ytest)
%% 
w = linregFitL2QR(mkUnitVariance(center(Xtrain)),center(ytrain), bestLambda); 
assert(isequal(model.w, w));
%%
model = linregFit(Xtrain, ytrain, 'kernelFn', @rbfKernel, 'doPlot', true);
set(gca, 'YScale', 'log');
yhat = linregPredict(model, Xtest);
mse = lossFn(yhat, ytest)
%%
model = linregFit(Xtrain, ytrain, 'regType', 'L1', ...
    'doPlot', true, 'fitMethod', 'interiorpoint');
yhat = linregPredict(model, Xtest);
mse = lossFn(yhat, ytest)



%%
model = linregFit(Xtrain, ytrain, 'regType', 'L1', 'kernelFn', @rbfKernel,...
    'lambda', 0.5:0.5:4, 'doPlot', true, 'fitMethod', 'interiorpoint', 'kernelParam', 3:0.5:4);
set(gca, 'YScale', 'log');
yhat = linregPredict(model, Xtest);
mse = lossFn(yhat, ytest)
%%
