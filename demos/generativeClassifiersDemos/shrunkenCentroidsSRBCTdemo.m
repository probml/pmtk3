% Try to reproduce fig 18.4 from "Elements of statistical learning" 2nd edn

%PMTKauthor Hannes Bretschneider
 
%% Import data
xtrain = importdata('khan.xtrain');
xtrain = xtrain';
ytrain = importdata('khan.ytrain');
ytrain = ytrain';
xtest = importdata('khan.xtest');
xtest = xtest';
fid = fopen('khan.ytest');
ytest = textscan(fid, '%n', 'delimiter', ' ',...
    'treatAsEmpty', 'NA');
fclose(fid);
ytest = ytest{1};
xtest = xtest(~isnan(ytest),:);
ytest = ytest(~isnan(ytest));


fitFn = @(X,y,lam)  naiveBayesGaussFitShrunkenCentroids(X, y, lam);
predictFn = @(model, X)  naiveBayesGaussPredict(model, X);


%% Error rates in the training and test sets for varying Delta
Deltas = linspace(0,8,20);
lDelta = length(Deltas);
nTrain = length(ytrain);
nTest = length(ytest);
for i=1:lDelta
    model = fitFn(xtrain, ytrain, Deltas(i));
    yhatTrain = predictFn(model, xtrain);
    yhatTest = predictFn(model, xtest);
    errTrain(i) = sum(zeroOneLossFn(yhatTrain, ytrain))/nTrain;
    errTest(i) = sum(zeroOneLossFn(yhatTest, ytest))/nTest;
    numgenes(i) = sum(model.relevant);
end

figure;
plot(Deltas, errTrain, 'go-', Deltas, errTest, 'bo:',...
  'MarkerSize', 4, 'linewidth', 2)
legend('Training', 'Test');
 
%% Cross validation
nFolds = 5;
useSErule = false;
[bestModel, bestDelta, errCV, se] = fitCV(Deltas, fitFn, predictFn,...
    @zeroOneLossFn, xtrain, ytrain, nFolds, useSErule); 

figure;
plot(Deltas, errTrain, 'go-', Deltas, errTest, 'bo:',...
    Deltas, errCV, 'ro-.', 'MarkerSize', 4, 'linewidth', 2)
legend('Training', 'Test', 'CV', 'Location', 'Best');
printPmtkFigure('shrunkenCentroidsErrVsLambda')

  
%% Plot centroids
centShrunk = bestModel.offset;
model = fitFn(xtrain, ytrain, 0);
centUnshrunk = model.offset;

[numGroups D] = size(centShrunk);
for g=1:numGroups
    %subplot(4,1,g);
    figure; hold on;
    plot(1:D, centUnshrunk(g,:), 'Color', [.8 .8 .8]);
    plot(1:D, centShrunk(g,:), 'b', 'LineWidth', 2);
    title(sprintf('Group %d', g));
    hold off;
    printPmtkFigure(sprintf('shrunkenCentroidsClass%d', g))
end
