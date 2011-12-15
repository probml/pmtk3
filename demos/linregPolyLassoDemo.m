%% lasso on polynomial regression
%

% This file is from pmtk3.googlecode.com

ns = [21];
for n=ns(:)'
setSeed(0);
[xtrain, ytrain, xtest, ytestNoisefree, ytest, sigma2] =...
  polyDataMake('sampling','thibaux','n',n);

deg = 14;

addOnes = false;
if ~addOnes
  % To avoid the need to add 1s to X, let us center the response
  %[y, ybar] = centerCols(y);
  %w   = fitFn(X, y, lambda);
  %model.w0  = ybar - mean(X)*w;
  ytrain = centerCols(ytrain);
  ytest = centerCols(ytest);
end

if 1
  % Because the dataset is so small, we proprocess it outside the
  % CV loop, so that all folds get the same treatment,
  %pp = preprocessorCreate('poly', deg, 'rescaleX', true, 'standardizeX', false, 'addOnes', false);
  pp = preprocessorCreate('poly', deg, 'rescaleX', true, 'standardizeX', true, 'addOnes', false);
  [pp, Xtrain] = preprocessorApplyToTrain(pp, xtrain);
  [Xtest] = preprocessorApplyToTest(pp, xtest);
  pp = preprocessorCreate( 'standardizeX', false, 'addOnes', addOnes);
else
  Xtrain = xtrain; Xtest = xtest;
  pp = preprocessorCreate('rescaleX', true, 'poly', deg, 'addOnes', addOnes);
end


%% Fit model by MLE and plot
modelOLS = linregFit(Xtrain, ytrain, 'preproc', pp);
[ypredTest] = linregPredict(modelOLS, Xtest);
figure;
scatter(xtrain, ytrain,'b','filled'); hold on;
plot(xtest, ypredTest, 'k', 'linewidth', 3);
title('MLE')
 
%% compute train/test error for each  lambda using lasso

NL = 20;
lambdaMax = lambdaMaxLasso(Xtrain, centerCols(ytrain));
%lambdas = linspace(1e-5, lambdaMax, nlambdas);
%lambdas  =  logspace(log10(lambdaMax), -20, NL);
lambdas = [lambdaMax, 10, 1, 0.5, 0.1, 0.01, 0.0001, 0];
%lambdas = [0, 0.00001, 0.001, 0.01, 0.1, 1, 10, 100];
NL = length(lambdas);
printNdx = round(linspace(2, NL-1, 3));
testMse = zeros(1,NL); trainMse = zeros(1,NL);
D = size(Xtrain, 2);
W = zeros(NL, D);
for k=1:NL
  lambda = lambdas(k);
  [model] = linregFit(Xtrain, ytrain, 'lambda', lambda, ...
      'regtype', 'L1', 'preproc', pp);
  W(k, :) = model.w';
  [ypredTest, s2] = linregPredict(model, Xtest);
  ypredTrain = linregPredict(model, Xtrain);
  testMse(k) = mean((ypredTest - ytest).^2);
  trainMse(k) = mean((ypredTrain - ytrain).^2);
end

latextable(W)

hlam=figure; hold on
dof = 1./(lambdas+1);
%ndx = dof;
%ndx =  log(lambdas); 
ndx = 1:length(lambdas);
fs = 12;
plot(ndx, trainMse, 'bs:', 'linewidth', 2, 'markersize', 12);
plot(ndx, testMse, 'rx-', 'linewidth', 2, 'markersize', 12);
legend('train', 'test', 'location', 'northwest', 'fontsize', fs)
xlabel('lambda', 'fontsize', fs)
ylabel('mse', 'fontsize', fs)
set(gca, 'xticklabel', lambdas, 'fontsize', fs)
% Indicate which lambda values were chosen for plotting
for i=printNdx(:)',  plot(ndx(i), 0, '*', 'markersize', 12, 'linewidth', 2); end
printPmtkFigure(sprintf('linregPolyVsRegTestErrN%d', n))

%% print fitted function for certain chosen lambdas
for k=printNdx
  lambda = lambdas(k);
  [model] = linregFit(Xtrain, ytrain, 'lambda', lambda, 'preproc', pp);
  [ypredTest, s2] = linregPredict(model, Xtest);
  ypredTrain = linregPredict(model, Xtrain);
  sig = sqrt(s2);
  figure;
  scatter(xtrain, ytrain,'b','filled');
  hold on;
  plot(xtest, ypredTest, 'k', 'linewidth', 3);
  plot(xtest, ypredTest + sig, 'b:');
  plot(xtest, ypredTest - sig, 'b:');
  title(sprintf('ln lambda %5.3f', log(lambda)))
  printPmtkFigure(sprintf('linregPolyVsRegFitK%dN%d', k, n))
end

end % for n