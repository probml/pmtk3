function [mseTest, w]= prostateLasso(X, y, ndxTrain, ndxTest)

% Reproduce fig 3.6 on p58 of "Elements of statistical learning" 

if nargin == 0
  load('prostate.mat') % from prostateDataMake
  [n d] = size(X);
  ndxTrain = find(istrain);
  ndxTest = setdiff(1:n, ndxTrain);
end

Nfolds = 10;
lambdas = [logspace(2, 0, 30) 0];

xtrainAll = X(ndxTrain,:); ytrainAll = y(ndxTrain);
seed= 0; rand('state', seed);
[n d] = size(xtrainAll);
perm = randperm(n);
xtrainAll = xtrainAll(perm,:);
ytrainAll = ytrainAll(perm);
[trainfolds, testfolds] = Kfold(size(xtrainAll,1), Nfolds);
clear mseCVTrain mseCVTest
errCVtest = [];
for f=1:length(trainfolds)
    xtrain = xtrainAll(trainfolds{f},:);
    ytrain = ytrainAll(trainfolds{f});
    xtestCV = xtrainAll(testfolds{f},:);
    ytestCV = ytrainAll(testfolds{f});
    [w, mseCVTrain(f,:), mseCVTest(f,:), df, errTest] = ...
    	LassoShootingPath(xtrain, ytrain, xtestCV, ytestCV, lambdas, 1);
end
mseCVMean = mean(mseCVTest,1);
mseCVse = std(mseCVTest,[],1)/sqrt(Nfolds);

figure;
%errorbar(df, mseCVMean, mseCVse);
errorbar(lambdas, mseCVMean, mseCVse);
kstar = oneStdErrorRule(mseCVMean, mseCVse);
hold on
ax = axis;
%line([df(kstar) df(kstar)], [ax(3) ax(4)], 'Color', 'r', 'LineStyle', '-.');
line([lambdas(kstar) lambdas(kstar)], [ax(3) ax(4)], 'Color', 'r', 'LineStyle', '-.');
xlabel('lambdas')
%xlabel('shrinkage factor t')
ylabel('cv error')

% Refit using optimal lambda
lambda = lambdas(kstar)
[w, mseTrain, mseTest] = ...
    LassoShootingPath(X(ndxTrain,:), y(ndxTrain), X(ndxTest,:), y(ndxTest), lambda, 1);
w

title(sprintf('lasso, mseTest = %5.3f', mseTest))
