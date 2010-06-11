%% Polynomial Regression Demo
%
%%
[xtrain, ytrain, xtest, ytestNoisefree, ytest] =...
    polyDataMake('sampling','thibaux');

deg = 14;
if 0
  [Xtrain] = rescaleData(xtrain);
  Xtrain = degexpand(Xtrain, deg, false);
  [Xtest] = rescaleData(xtest);
  Xtest = degexpand(Xtest, deg, false);
  pp = preprocessorCreate();
else
  Xtrain = xtrain; Xtest = xtest;
  pp = preprocessorCreate('rescaleX', true, 'poly', deg);
end




%% Plot regularized fit for various lambdas
lambdas = [0, 0.00001, 0.001];
NL = length(lambdas);
for k=1:NL
    lambda = lambdas(k);
    if 0
      model = linregFitBayes(Xtrain, ytrain, 'prior', 'gauss', 'alpha', lambda, 'beta', 1, 'preproc', pp);
      [ypredTest, s2] = linregPredictBayes(model, Xtest);
    else
       model = linregFit(Xtrain, ytrain, 'lambda', lambda, 'preproc', pp);
      [ypredTest, s2] = linregPredict(model, Xtest);
    end 
    sig = sqrt(s2);   
    figure; 
    scatter(xtrain, ytrain,'b','filled');
    hold on;
    plot(xtest, ypredTest, 'k', 'linewidth', 3);
    plot(xtest, ypredTest + sig, 'b:');
    plot(xtest, ypredTest - sig, 'b:');
    title(sprintf('ln lambda %5.3f', log(lambda)))
end

%% Now compute train/test error for each  lambda
lambdas = logspace(-10,1.2,9);
NL = length(lambdas);
 testMse = zeros(1,NL); trainMse = zeros(1,NL);
for k=1:NL
    lambda = lambdas(k);
    [model] = linregFit(Xtrain, ytrain, 'lambda', lambda, 'preproc', pp);
    ypredTest = linregPredict(model, Xtest);
    ypredTrain = linregPredict(model, Xtrain);
    testMse(k) = mean((ypredTest - ytest).^2); 
    trainMse(k) = mean((ypredTrain - ytrain).^2);
end

figure; hold on
ndx =  log(lambdas); % 1:length(lambdas);
plot(ndx, trainMse, 'bs:', 'linewidth', 2, 'markersize', 12);
plot(ndx, testMse, 'rx-', 'linewidth', 2, 'markersize', 12);
legend('train mse', 'test mse', 'location', 'northwest')
xlabel('log regularizer')
printPmtkFigure('linregL2PolyVsReg-mse')

