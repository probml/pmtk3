function model = smlrFit(X, y, varargin)
%% Fit a sparse multinomial logistic regression model using L1+CV
% 
%
% Optional inputs:
% kernelFn  ... should be a fn of the form @(X1, X2).
% pathOpts ... structure passed to logregFitPathCv
% regType ... L1 or L2 (default is L1)
% usePath ... if true, builds kernel basis once then calls 
%  logregFitPathCv to pick lambda based on regpath.
%  If false, builds different kernel basis on each fold
%  while selecting lambda from finite grid.
%  The latter seems to work better.
% lambdaRange ... Range to search over if not using path

% This file is from pmtk3.googlecode.com


pathOpts = glmnetSet();
pathOpts.standardize = false;

% default kernel
kernelFn = @(X1,X2) kernelRbfGamma(X1,X2,1);

% default range - % a bit arbitrary
lambdaRange = logspace(-5, 2, 10); 

[kernelFn, regType, pathOpts, usePath, lambdaRange] = process_options(...
  varargin, ...
  'kernelFn', kernelFn, ...
  'regType', 'L1', ...
  'pathOpts', pathOpts, ...
  'usePath', false, ...
  'lambdaRange', lambdaRange); 

K = nunique(y);
[y, ySupport] = setSupport(y, 1:K);

pp = preprocessorCreate('kernelFn', kernelFn);
if usePath
  [pp, Xbasis] = preprocessorApplyToTrain(pp, X);
    [model.bestPathModel, model.path] = logregFitPathCv(Xbasis, y, 'regType', regType, ...
    'options', pathOpts);
  model.preproc = pp;
else
  fitFn = @(X, y, param)logregFit(X, y, 'lambda' , param, 'regType', regType,...
    'preproc', pp);
  predictFn = @logregPredict;
  lossFn = @(yTest, yHat)mean(yHat ~= yTest);
  nfolds = 5;
  [model, bestParams]  = fitCv(lambdaRange, fitFn, predictFn, lossFn, X, y, nfolds);
  model.bestLambda = bestParams;
end
model.usePath = usePath;
model.ySupport   = ySupport; 

end

