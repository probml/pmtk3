%% Reproduce figure 18.4 from "Elements of statistical learning" 2nd ed.
%
%%

% This file is from pmtk3.googlecode.com


loadData('srbct'); % Xtrain is 63*2308, Xtest is 25*2308, C=4

Xtest = Xtest(~isnan(ytest), :);
ytest = ytest(~isnan(ytest));

fitFn = @(X,y,lam)  discrimAnalysisFit(X, y, 'shrunkenCentroids', 'lambda', lam);
predictFn = @(model, X)  discrimAnalysisPredict(model, X);


%% Error rates in the training and test sets for varying Delta
lambdas = linspace(0, 8, 20);
nTrain = length(ytrain);
nTest = length(ytest);
for i=1:length(lambdas)
    model = fitFn(Xtrain, ytrain, lambdas(i));
    yhatTrain = predictFn(model, Xtrain);
    yhatTest = predictFn(model, Xtest);
    errTrain(i) = sum(zeroOneLossFn(yhatTrain, ytrain))/nTrain;
    errTest(i) = sum(zeroOneLossFn(yhatTest, ytest))/nTest;
    numgenes(i) = sum(model.shrunkenCentroids(:) ~= 0);
end

figure;
plot(lambdas, errTrain, 'gx-', lambdas, errTest, 'bo--',...
  'MarkerSize', 10, 'linewidth', 2)
legend('Training', 'Test', 'Location', 'northwest');
xlabel('Amount of shrinkage')
ylabel('misclassification rate')
title('SRBCT data')


%% Cross validation
% We have to combine train and test sets to get the same
% CV curve as in Hastie fig 18.4...
nFolds = 10;
useSErule = false;
[bestModel, bestDelta, errCV, se] = fitCv(lambdas, fitFn, predictFn,...
    @zeroOneLossFn, [Xtrain;Xtest], [ytrain;ytest], nFolds, 'useSErule', useSErule); 

  figure;
lambda = lambdas;
xticklam=[1:8];
xtickNgenes = numgenes(round(linspace(1,length(numgenes), length(xticklam))));
axisH=axes;
set(axisH,'xlabel',xlabel('Number of Genes'),'layer','top',...
  'xaxislocation','top','xlim',[xticklam(1) xticklam(end)],'xminortick','on',...
  'ytick',[],'yticklabel',[],'xticklabel',xtickNgenes,'xtick',xticklam);
hold on
axes('position',get(axisH,'position'),'xminortick','on','xtick',xticklam,'xticklabel',xticklam,'layer','bottom')
hold on
plot(lambda,errTest,'bo--','markersize',10,'linewidth',2)
plot(lambda,errTrain,'gx-','markersize',10,'linewidth',2)
plot(lambda,errCV,'rs:','markersize',10,'linewidth',2)
axis([0 lambda(end) 0 1])
xlabel('\lambda')
ylabel('Misclassification Error','position',[-0.7 0.49 1.001])
%ticks=get(gca,'ytick');
%set(gca,'yticklabel',[]);
%text(ticks*0-0.3,ticks-0.02,cellstr(num2str(ticks')),'rotation',90,'fontsize',15)
legend( 'Test', 'Train', 'CV', 'Location', 'Best');
bestNdx  = find(bestDelta==lambdas);
fprintf('best lambda=%5.3f, ngenes = %d\n', bestDelta, numgenes(bestNdx));
line([bestDelta bestDelta], [0 1]);
printPmtkFigure('shrunkenCentroidsErrVsLambda')
  
%% Plot centroids
centShrunk = bestModel.shrunkenCentroids;
model = fitFn(Xtrain, ytrain, 0);
centUnshrunk = model.shrunkenCentroids;

[numGroups D] = size(centShrunk);
for g=1:numGroups
    %subplot(4,1,g);
    figure; hold on;
    plot(1:D, centUnshrunk(g,:), 'Color', [.8 .8 .8]);
    plot(1:D, centShrunk(g,:), 'b', 'LineWidth', 2);
    title(sprintf('Class %d', g));
    hold off;
    printPmtkFigure(sprintf('shrunkenCentroidsClass%d', g))
end


