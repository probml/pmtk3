function knnClassifyDemo()

K = 1;

% from knnClassifyMakeData
C = 3; % num classes
tmp = dlmread('knnClassify3CTrain.txt',  ' ');
Xtrain = tmp(:,1:2); ytrain = tmp(:,3);
tmp = dlmread('knnClassify3CTest.txt',  ' ');
Xtest = tmp(:,1:2); ytest = tmp(:,3);

Ntest = size(Xtest,1);
Ntrain = size(Xtrain,1)

range = [min(Xtrain(:,1)) max(Xtrain(:,1)) min(Xtrain(:,2)) max(Xtrain(:,2))];

figure;
plotLabeledData(Xtrain, ytrain)
title('train')
axis(range)
printPmtkFigure('knnClassifyTrainData'); 

figure;
plotLabeledData(Xtest, ytest)
title('test - truth')
axis(range)
printPmtkFigure('knnClassifyTestData'); 



Ks = [1 5];
for K=Ks(:)'
  [ypred] = knnClassify(Xtrain, ytrain, Xtest, K);
  figure;
  plotLabeledData(Xtest, ypred);
  err = find(ypred(:) ~= ytest(:));
  nerrors = sum(ypred(:) ~= ytest(:));
  title(sprintf('K=%d, error rate = %d/%d = %5.3f', ...
		K, nerrors, Ntest, nerrors/Ntest))
  axis(range)
  % Put circles around errors
  hold on
  h=plot(Xtest(err,1), Xtest(err,2), 'ko'); set(h,'markersize',15)
  printPmtkFigure(sprintf('knnClassifyTestK%d', K)); 
end



% Plot  predicted class  across a grid of points
% cf HTF fig 2.2

XtestGrid = makeGrid2d(Xtrain);
Ks = [1 5];
for K=Ks(:)'
  ypredGrid = knnClassify(Xtrain, ytrain, XtestGrid, K);
  figure;
  plotLabeledData(XtestGrid, ypredGrid)
  %axis([min(x1range) max(x1range) min(x2range) max(x2range)])
  axis(range)
  %title(sprintf('mode of predictive density, K=%d', K))
  title(sprintf('predicted label,  K=%d', K))
  printPmtkFigure(sprintf('knnClassifyGridC%dK%d.eps', C, K))
end



%%%%%%
function plotLabeledData(X, y)

markers = {'r+', 'b*', 'gx'};
C = max(y);
for c=1:C
  ndx = find(y==c);
  h=plot(X(ndx,1), X(ndx,2), markers{c});
  set(h,'markersize',12)
  hold on
end
