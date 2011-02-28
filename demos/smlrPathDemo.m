%% Compare SMLR selecting lambda on grid or on path.
% If  path, we use the same kernel basis for all lambda
% If grid, we change the basis depending on the fold.
%
% See also linearKernelDemo

% This file is from pmtk3.googlecode.com

%PMTKslow

% Results: rows  = soy, colon
% cols = 'smlrPath', 'smlrNoPath', 'rmlrPath', 'rmlrNoPath'
%{
testErrRate =
    0.2366    0.0860    0.0860    0.0323
    0.5789    0.3158    0.3158    0.2105

trainingTime =
    3.1635   45.5373    0.0000   25.3579
    0.6405    2.5856    0.0000    3.0739
%}
    
clear all
setSeed(0);

%% Data
split = 0.7;
d = 1;

if 1
loadData('soy') % 3 classes, X is 307*35
dataSets(d).X = X; 
dataSets(d).y = Y; 
dataSets(d).name = 'soy';
d=d+1;
end

if 0
loadData('fglass'); % 6 classes, X is 214*9
X = [Xtrain; Xtest];
y = canonizeLabels([ytrain; ytest]); % class 4 is missing, so relabel 1:6
dataSets(d).X = X; 
dataSets(d).y = y; 
dataSets(d).name = 'fglass';
d=d+1;
end

if 1
loadData('colon') % 2 class, X is 62*2000
dataSets(d).X = X;
dataSets(d).y = y;
dataSets(d).name = 'colon';
d=d+1;
end

if 0
loadData('amlAll'); % 2 class, X is 72*7129
X = [Xtrain; Xtest];
y = [ytrain; ytest]; 
dataSets(d).X = X;
dataSets(d).y = y;
dataSets(d).name = 'amlAll';
d=d+1;
end

dataNames = {dataSets.name};
nDataSets = numel(dataSets);


%% Models
methods = {'smlrPath', 'smlrNoPath', 'rmlrPath', 'rmlrNoPath'};
if ~glmnetInstalled
  methods = setdiff(methods, 'smlrPath');
  methods = setdiff(methods, 'rmlrPath');
end

nMethods = numel(methods);

%% Main
for d=1:nDataSets
  setSeed(0);
  X = dataSets(d).X;
  y = dataSets(d).y;
  [X, y] = shuffleRows(X, y);
  X      = rescaleData(standardizeCols(X));
  N      = size(X, 1);
  nTrain = floor(split*N);
  nTest  = N - nTrain;
  Xtrain = X(1:nTrain, :);
  Xtest  = X(nTrain+1:end, :);
  ytrain = y(1:nTrain);
  ytest  = y(nTrain+1:end);
  
  for m=1:nMethods
    method = methods{m};
    tic;
    
    switch lower(method)
      case 'svm'
        % SVMpath functionality not yet implemented
        % so internally we do CV over C
        Crange = logspace(-5, 5, 10);
        model = svmFit(Xtrain, ytrain, 'C', Crange,  'kernel', 'linear');
        predFn = @(m,X) svmPredict(m,X);
      case 'rvm'
        model = rvmFit(Xtrain, ytrain, [], 'kernelFn', @kernelLinear);
        predFn = @(m,X) rvmPredict(m,X);
      case 'smlrpath'
        model = smlrFit(Xtrain, ytrain, 'kernelFn', @kernelLinear, ...
          'usePath', true);
        predFn = @(m,X) smlrPredict(m,X);
      case {'smlrnopath', 'smlr'}
        model = smlrFit(Xtrain, ytrain,  'kernelFn', @kernelLinear, ...
          'usePath', false);
        predFn = @(m,X) smlrPredict(m,X);
      case 'rmlrpath'
        model = smlrFit(Xtrain, ytrain, 'kernelFn', @kernelLinear, ...
          'regtype', 'L2', 'usePath', true);
        predFn = @(m,X) smlrPredict(m,X);
      case {'rmlrnopath', 'rmlr'}
        model = smlrFit(Xtrain, ytrain, 'kernelFn', @kernelLinear, ...
          'regtype', 'L2', 'usePath', false);
        predFn = @(m,X) smlrPredict(m,X);
      case 'logregl2'
        model = logregFitPathCv(Xtrain, ytrain, 'regtype', 'L2');
        predFn = @(m,X) logregPredict(m,X);
      case 'logregl1'
        model = logregFitPathCv(Xtrain, ytrain, 'regtype', 'L1');
        predFn = @(m,X) logregPredict(m,X);
    end
    trainingTime(d,m) = toc;
    saveModel{d,m} = model;
    
    tic
    yHat   = predFn(model, Xtest);
    testingTime(d,m) = toc;
    
    nerrs  = sum(yHat ~= ytest);
    testErrRate(d,m) = nerrs/nTest;
    
  end
end

 testErrRate
 
 trainingTime
 
 
