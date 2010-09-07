%% Fit a rbf kernel binary logistic regression model to the crabs data 
loadData('crabs');
% Here we cross validate over both lambda and Sigma
lambda     = logspace(-4, 0, 10); %logspace(-7, -4, 20); 
Sigma      = 2:2:10; % 8:0.5:10;
paramRange = crossProduct(lambda, Sigma); 
regtypes = {'L1', 'L2'};
for r=1:length(regtypes)
  regtype = regtypes{r};
  
  fitFn = @(X, y, param)...
    logregFit(X, y, 'lambda', param(1), 'regType', regtype, 'preproc', ...
    preprocessorCreate('kernelFn', @(X1, X2)kernelRbfSigma(X1, X2, param(2))));
  %%
  predictFn = @logregPredict;
  lossFn = @(ytest, yhat)mean(yhat ~= ytest);
  nfolds = 5;
  useSErule = true;
  plotCv = true;
  tic;
  [LRmodel, lambdaStar, LRmu, LRse] = ...
    fitCv(paramRange, fitFn, predictFn, lossFn, Xtrain, ytrain, nfolds, ...
    'useSErule', useSErule, 'doPlot', plotCv, 'params1', lambda, 'params2', Sigma);
  time(r) = toc
  yhat = logregPredict(LRmodel, Xtest);
  nerrors(r) = sum(yhat ~= ytest)
end




