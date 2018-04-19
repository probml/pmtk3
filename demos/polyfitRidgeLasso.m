%% Ridge and lasso regression: 
% visualize effect of changing lambda on degree 14 polynomial
%
% This is a simplified version of linregPolyVsRegDemo.m

%ns = [21 50];
%for n=ns(:)'
  n = 21;
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
  pp = preprocessorCreate('poly', deg, 'rescaleX', true, 'standardizeX', false, 'addOnes', false);
  [pp, Xtrain] = preprocessorApplyToTrain(pp, xtrain);
  [Xtest] = preprocessorApplyToTest(pp, xtest);
  pp = preprocessorCreate( 'standardizeX', false, 'addOnes', addOnes);
else
  Xtrain = xtrain; Xtest = xtest;
  pp = preprocessorCreate('rescaleX', true, 'poly', deg, 'addOnes', addOnes);
end


%% Fit model by MLE and plot
model = linregFit(Xtrain, ytrain, 'preproc', pp);
%for i=1:14, fprintf('%5.3f, ', model.w(i)); end
[ypredTest] = linregPredict(model, Xtest);
figure;
scatter(xtrain, ytrain,'b','filled'); hold on;
plot(xtest, ypredTest, 'k', 'linewidth', 3);


%% compute train/test error for each  lambda using ridge
lambdas = logspace(-10,1.3,10);
NL = length(lambdas);
testMse = zeros(1,NL); trainMse = zeros(1,NL);
for k=1:NL
  lambda = lambdas(k);
  [model] = linregFit(Xtrain, ytrain, 'lambda', lambda, 'preproc', pp);
  [ypredTest, s2] = linregPredict(model, Xtest);
  ypredTrain = linregPredict(model, Xtrain);
  testMse(k) = mean((ypredTest - ytest).^2);
  trainMse(k) = mean((ypredTrain - ytrain).^2);
end


hlam=figure; hold on
ndx =  log(lambdas); % 1:length(lambdas);
plot(ndx, trainMse, 'bs:', 'linewidth', 2, 'markersize', 12);
plot(ndx, testMse, 'rx-', 'linewidth', 2, 'markersize', 12);
legend('train mse', 'test mse', 'location', 'northwest')
xlabel('log lambda')
title('mean squared error')
% Indicate which lambda values were chosen for plotting
%for i=printNdx(:)',  plot(ndx(i), 0, '*', 'markersize', 12, 'linewidth', 2); end
printPmtkFigure(sprintf('polyfitRidgeUcurve'))



%% print fitted function for certain chosen lambdas
% We will store all the coefficients for each model so we can make a table
% to illustrate how they get smaller as lambda inceeases
L2lambdas = [1e-4, 1e-1];
L2coefs = zeros(deg, length(L2lambdas));
for k=1:length(L2lambdas)
  lambda = L2lambdas(k);
  fprintf('ridge %f\n', lambda);
  [model] = linregFit(Xtrain, ytrain, 'lambda', lambda, 'preproc', pp);
  %for i=1:14, fprintf('%5.2f, ', model.w(i)); end; fprintf('\n');
  L2coefs(:,k) = model.w;
  [ypredTest, s2] = linregPredict(model, Xtest);
  ypredTrain = linregPredict(model, Xtrain);
  sig = sqrt(s2);
  figure;
  scatter(xtrain, ytrain,'b','filled');
  hold on;
  plot(xtest, ypredTest, 'k', 'linewidth', 3);
  plot(xtest, ypredTest + sig, 'b:');
  plot(xtest, ypredTest - sig, 'b:');
  %title(sprintf('ln lambda %5.3f', log(lambda)))
  title(sprintf('L2 lambda= %5.3e', lambda))
  %printPmtkFigure(sprintf('linregPolyVsRegFitK%dN%d', k, n))
  printPmtkFigure(sprintf('polyfitRidgeK%d', k))
end



%% print fitted function for certain chosen lambdas using lasso
L1lambdas = [0.1, 10.0];
L1coefs = zeros(deg, length(L1lambdas));
for k=1:length(L1lambdas)
  lambda = L1lambdas(k);
  fprintf('lasso %f\n', lambda);
  [model] = linregFit(Xtrain, ytrain, 'regtype', 'l1', 'fitFnName', 'l1ls', 'lambda', lambda, 'preproc', pp);
  %or i=1:14, fprintf('%5.2f, ', model.w(i)); end; fprintf('\n');
  L1coefs(:, k) = model.w;
  [ypredTest, s2] = linregPredict(model, Xtest);
  ypredTrain = linregPredict(model, Xtrain);
  sig = sqrt(s2);
  figure;
  scatter(xtrain, ytrain,'b','filled');
  hold on;
  plot(xtest, ypredTest, 'k', 'linewidth', 3);
  plot(xtest, ypredTest + sig, 'b:');
  plot(xtest, ypredTest - sig, 'b:');
  %title(sprintf('ln lambda %5.3f', log(lambda)))
  title(sprintf('L1 lambda= %5.3e', lambda))
  printPmtkFigure(sprintf('polyfitRidgeLassoK%d', k))
end

coefs = [L2coefs L1coefs];
for i=1:deg
    fprintf('%d & %5.3f & %5.3f & %5.3f & %5.3f\\\\\n', ...
    i, coefs(i,1), coefs(i,2), coefs(i,3), coefs(i,4))
end

