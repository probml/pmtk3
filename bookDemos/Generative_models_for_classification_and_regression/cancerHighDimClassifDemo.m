%% Try to reproduce table 18.1 from "Elements of statistical learning" 2nd edn p656
%PMTKauthor Hannes Bretschneider
%PMTKslow
%
%% Load data

loadData('14cancer') % Xtrain is 144*16063, Xtest is 54*16063
ytrain = colvec(ytrain);
ytest = colvec(ytest); 
% on p654, they say "the data from each patient (row) is standardized
% to have mean 0 and variance 1"
xtrain_std = standardizeCols(Xtrain')';
xtest_std = standardizeCols(Xtest')';
[N, D] = size(xtrain_std);
clear Xtest Xtrain 

% we can either explicitly use the same folds as Hastie
% or we can choose our own (which lets us control computation time)
% The dataset is so small that some classes might not be present
% in any given training fold. The Hastie folds have been carefully
% chosen to avoid this (although it is really the algorithm's job
% to handle this eg by using priors).
if 1
  folds = folds.data(:,2:size(folds.data,2));
  Nfolds = [];
else
  Nfolds = 3;
  folds = [];
end



%% Run methods
% L1 is very slow, L2 is somewhat slow

%methods = {'nsc', 'nb', 'rda', 'knn', 'l2logreg', 'svm', 'l1logreg'}; 
%methods = {'nsc', 'nb', 'rda', 'knn', 'l2logreg', 'svm'}; 
%methods = {'nsc', 'nb', 'rda', 'knn', 'svm'};
methods = {'diag', 'nb'}; 

% warning - l1logreg can take upwards of 6 hours to run. 
M = length(methods);

for m=1:M
  method = methods{m};
  switch method
    case 'nsc'
      name{m} = 'Nearest shrunken centroids';
      params = linspace(0, 10, 10)';
      fitFn = @naiveBayesGaussFitShrunkenCentroids;
      predictFn = @naiveBayesGaussPredict;
      noGenesFn = @(model)sum(model.relevant);
    case 'nb'
      name{m} = 'Naive bayes';
      params = 1;
      fitFn = @(X, y, param)naiveBayesGaussFit(X, y);
      predictFn = @naiveBayesGaussPredict;
      noGenesFn = @(model)D;
    case 'diag'
      name{m} = 'Diagonal QDA';
      params = 1;
      fitFn = @(X, y, param) discrimAnalysisFit(X, y, 'diag');
      predictFn = @discrimAnalysisPredict;
      noGenesFn = @(model)D;
    case 'rda'
      name{m} = 'Regularized discriminant analysis';
      %params = linspace(0, 2, 10)';
       params = linspace(0, 2, 5)';
      % we don't have to do multiple SVDs, since we
      % are just changing the weighting term
      [U S V] = svd(xtrain_std, 'econ');
      R = U*S;
      %fitFn = @(X, y, gamma)RDAfit(X, y, gamma, 'R', R, 'V', V);
      %predictFn = @RDApredict;
      fitFn = @(X,y, lambda) discrimAnalysisFit(X, y, 'rda', lambda, R, V);
      predictFn = @discrimAnalysisPredict;
      noGenesFn = @(model)D;
    case 'knn'
      name{m} = 'k-nearest neighbors';
      params = (1:3)';
      fitFn = @knnFit;
      predictFn = @knnPredict;
      noGenesFn = @(model)D;
    case 'l2logreg'
      name{m} = 'l2logreg';
      params = linspace(0, 10, 10)';
      fitFn = @(X, y, lambda)logregFitL2Dual(X, y, lambda);
      predictFn = @logregPredict;
      noGenesFn = @(m) D;
    case 'l1logreg'
      name{m} = 'l1-penalized logistic regression';
      params = linspace(1, 10, 10)';
      fitFn = @(X, y, param)logregFit(X, y, 'lambda', param,...
        'regType', 'L1', 'fitOptions', struct('corrections', 50, 'maxIter', 20));
      predictFn = @logregPredict;
      noGenesFn = @(model) sum(sum(model.w,1)~=0);
    case 'svm'
      params =  logspace(-1,1,5)';
      name{m} = 'SVM';
      fitFn = @(X, y, param) svmFit(X, y, 'kernel', 'linear', 'C', param); 
      predictFn = @svmPredict;
      noGenesFn = @(model) D; %sum(sum(model.w,1)~=0);
  end
  
  useSErule=0; doPlot=0; plotArgs= [];
  [model{m}, bestParam(m)] = fitCv(params,...
    fitFn, predictFn, @zeroOneLossFn, xtrain_std, ytrain, ...
    Nfolds, useSErule, doPlot, plotArgs,  folds);
  %ndx = find(err==min(err), 1);
  %lossCv(m)= err(ndx); seCv(m) = se(ndx);
  yhat = predictFn(model{m}, xtest_std);
  lossTest(m) = sum(zeroOneLossFn(yhat, ytest));
  noGenes(m) = noGenesFn(model{m});
end

%% Print results
latextable([lossTest' noGenes' bestParam'],...
     'Horiz', {'Test errors', 'Genes used', 'Best Param'},...
     'Vert', name, 'name', '')

for m=1:M
  fprintf('method %s, test errors %d, ngenes %d, best param %5.3f\n', ...
    name{m}, lossTest(m), noGenes(m), bestParam(m));
end

