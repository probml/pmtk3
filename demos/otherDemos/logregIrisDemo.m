%% Multi-class logistic regression on iris data

loadData('fisheriris')
X = meas;  % 150x4
[y, support] = canonizeLabels(species);
pp = preprocessorCreate('standardizeX', false, 'addOnes', true);

% Empirical Bayes
modelEB = logregFitBayes(X, y, 'method', 'eb', 'preproc', pp);
[yhatEB, pEB] = logregPredictBayes(modelEB, X);
errRateEB = mean(yhatEB ~= y)

% MAP estimation with different values of  alpha
lambdas = [modelEB.netlab.alpha 0.001 1000];
for i=1:length(lambdas)
  lambda = lambdas(i);
  model = logregFit(X, y, 'lambda', lambda, 'preproc', pp);
  [yhat, p] = logregPredict(model, X);
  errRate = mean(yhat ~= y);
  fprintf('lambda = %6.4f, error rate = %5.3f\n', lambda, errRate);
end
