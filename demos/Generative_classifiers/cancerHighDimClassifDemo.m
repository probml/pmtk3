% Try to reproduce table 18.1 from "Elements of statistical learnign" 2nd edn p656
%PMTKauthor Hannes Bretschneider

%% Load data

load('14cancer.mat') % modified data so X is N*D as usual
ytrain = colvec(ytrain);
ytest = colvec(ytest); 
% on p654, they say "the data from each patient (row) is standardized
% to have mean 0 and variance 1"
xtrain_std = standardizeCols(Xtrain')';
xtest_std = standardizeCols(Xtest')';
[N, D] = size(xtrain_std);

% we can either explicitly use the same folds as Hastie
% or we can choose our own (which lets us control
% computation time)
if 0
  folds = importdata('cvfolds.txt');
  folds = folds.data(:,2:size(folds.data,2));
  Nfolds = [];
else
  Nfolds = 3;
  folds = [];
end



%% Run methods
% L1 and SVM are very slow, L2 is fairly slow

methods = {'nsc', 'nb', 'rda', 'knn', 'l2logreg', 'svm', 'l1logreg'}; % };
M = length(methods);

for m=1:M
  method = methods{m};
  switch method
    case 'nsc'
      name{m} = 'Nearest shrunken centroids';
      params = linspace(0, 10, 10);
      fitFn = @naiveBayesGaussFitShrunkenCentroids;
      predictFn = @naiveBayesGaussPredict;
      noGenesFn = @(model)sum(model.relevant);
    case 'nb'
      name{m} = 'Naive bayes';
      params = 1;
      fitFn = @(X, y, param)naiveBayesGaussFit(X, y);
      predictFn = @naiveBayesGaussPredict;
      noGenesFn = @(model)D;
    case 'rda'
      name{m} = 'Regularized discriminant analysis';
      params = linspace(0, 2, 10);
      % we don;t have to do multiple SVDs, since we
      % are just changing the weighting term
      [U S V] = svd(xtrain_std, 'econ');
      R = U*S;
      fitFn = @(X, y, gamma)RDAfit(X, y, gamma, 'R', R, 'V', V);
      predictFn = @RDApredict;
      noGenesFn = @(model)D;
    case 'knn'
      name{m} = 'k-nearest neighbors';
      params = 1:3;
      fitFn = @knnFit;
      predictFn = @knnPredict;
      noGenesFn = @(model)D;
    case 'l2logreg'
      name{m} = 'l2logreg';
      params = linspace(0, 10, 10);
      fitFn = @(X, y, lambda)logregFitL2Dual(X, y, lambda);
      predictFn = @logregPredict;
      noGenesFn = @(m) D;
    case 'l1logreg'
      name{m} = 'l1-penalized logistic regression';
      params = linspace(1, 10, 10);
      fitFn = @(X, y, param)logregFit(X, y, 'lambda', param,...
        'regType', 'L1', 'fitMethod', 'minFunc');
      predictFn = @logregPredict;
      noGenesFn = @(model)D;
    case 'svm'
      params =  logspace(-1,1,5);
      name{m} = 'SVM';
      fitFn = @(X, y, param) svmFit(X, y, 'kernel', 'linear', 'C', param); 
      predictFn = @svmPredict;
      noGenesFn = @(model) D; %sum(sum(model.w,1)~=0);
  end
  
  useSErule=0; doPlot=0; plotArgs= [];
  [model{m}, bestParam{m}] = fitCv(params,...
    fitFn, predictFn, @zeroOneLossFn, xtrain_std, ytrain, ...
    Nfolds, useSErule, doPlot, plotArgs,  folds);
  %ndx = find(err==min(err), 1);
  %lossCv(m)= err(ndx); seCv(m) = se(ndx);
  yhat = predictFn(model{m}, xtest_std);
  lossTest(m) = sum(zeroOneLossFn(yhat, ytest));
  noGenes(m) = noGenesFn(model{m});
end

%% Print results
% latextable([lossCv' seCv' lossTest' noGenes'],...
%     'Horiz', {'CV errors', 'SE', 'Test errors', 'Genes used'},...
%     'Vert', name)

for m=1:M
  fprintf('method %s, test errors %d, ngenes %d, best param %5.3f\n', ...
    name{m}, lossTest(m), noGenes(m), bestParam{m});
end

