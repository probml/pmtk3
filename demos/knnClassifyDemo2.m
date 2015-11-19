% Same as logregMultinomKernelDemo, except uses KNN
% This produces plots of the decision boundaries in 2d.
% It uses the same data as knnClassifyDemo, but the plots look nicer.

% This file is from pmtk3.googlecode.com

function knnClassifyDemo2()
%% Setup Data

loadData('knnClassify3c'); % 500 samples from 2 classes
X = Xtrain;
y = ytrain;

%% Fit models

Ks = [1, 5, 10];
modelKNN= {};
for K=Ks(:)'
    modelKNN{K} = knnFit(X, y, K); 
end
  
%% Compute training errors

for K=Ks(:)'
    [yhat] = knnPredict(modelKNN{K}, X);
    trainErr_knn = mean(y~=yhat);
    fprintf('Training error using KNN with K=%d: %4.2f%%\n', K, trainErr_knn*100);
end

%% Plot decision boundaries

for K=Ks(:)'
predictFcn = @(Xtest) knnPredict(modelKNN{K}, Xtest); 
plotDecisionBoundary(X, y, predictFcn);
title(sprintf('KNN with K=%d', K));
printPmtkFigure(sprintf('knnClassify%dBoundary', K));
end

%% Plot error vs K
Ks = [1 5 10 20 50 100 120];
Ntrain = length(ytrain);
Ntest = length(ytest);
for ki=1:length(Ks)
  K = Ks(ki);
  model = knnFit(Xtrain, ytrain, K); 
  [ypred] = knnPredict(model, Xtest);
  err = find(ypred(:) ~= ytest(:));
  nerrors = length(err);
  errRateTest(ki) = nerrors/Ntest;
 
  % compute error on training set
  [ypred] = knnPredict(model, Xtrain);
  err = find(ypred(:) ~= ytrain(:));
  nerrors = length(err);
  errRateTrain(ki) = nerrors/Ntrain;
end

figure; 
plot(Ks, errRateTrain, 'bs:', Ks, errRateTest, 'rx-', 'linewidth', 3, 'markersize', 20);
legend('train', 'test')
xlabel('K'); ylabel('misclassification rate')
printPmtkFigure('knnClassifyErrVsK')


end
