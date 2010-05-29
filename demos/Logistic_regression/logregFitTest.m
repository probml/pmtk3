%% Simple tests of logregFit
%
%%
loadData('crabs');
%%
model = logregFit(Xtrain, ytrain, 'lambda', 0);
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest)
%%
model = logregFit(Xtrain, ytrain);
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest)
%%
model = logregFit(Xtrain, ytrain, 'regType', 'L1', 'fitFn', @logregFitL1Minfunc);
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest)
%%
preproc.kernelFn = @(X1, X2)kernelRbfSigma(X1, X2, 8);
model = logregFit(Xtrain, ytrain, 'regType', 'L1', 'nlambdas', 3, ...
    'preproc', preproc);
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest) 
%%
model = logregFit(Xtrain, ytrain, 'regType', 'L2', 'nlambdas', 100);
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest) 
%%
preproc.kernelFn = @(X1, X2)kernelRbfSigma(X1, X2, 10);
model = logregFit(Xtrain, ytrain, 'regType', 'L1', 'lambda', 1e-6, ...
    'preproc', preproc, 'fitFn', @L1GeneralGrafting);
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest) 
%% 

