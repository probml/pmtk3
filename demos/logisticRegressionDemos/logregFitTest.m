%% Simple tests of logregFit
%PMTKslow
load crabs
%%
model = logregFit(Xtrain, ytrain, 'lambda', 0);
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest)
%%
model = logregFit(Xtrain, ytrain);
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest)
%%
model = logregFit(Xtrain, ytrain, 'regType', 'L1', 'fitMethod', 'minfunc');
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest)
%%
[model,bestParams] = logregFit(Xtrain, ytrain, 'regType', 'L1',... 
        'kernelFn', @rbfKernel, 'nlambdas', 3, 'nkernelParams', 3);
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest) 
%%
model = logregFit(Xtrain, ytrain, 'regType', 'L1',... 
        'kernelFn', @rbfKernel, 'lambda', 1e-6, 'kernelParam', 10, 'fitMethod', 'grafting');
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest) 
%% 

model = logregFit(Xtrain, ytrain,...
    'lambda', 0:0.001:0.01, 'kernelParam', 7:0.1:10, 'regType', 'L2','kernelFn', @rbfKernel, 'doPlot', true);
yhat  = logregPredict(model, Xtest);
nerr  = sum(yhat ~= ytest) 

