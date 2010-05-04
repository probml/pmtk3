%% Posterior predictive density for Bayesian linear Regression in 1d with Polynomial Basis 
% We use a gaussian prior with fixed noise variance
% We plot the posterior predictive density, and samples from it

setSeed(0);
[xtrain, ytrain, xtest, ytestNoisefree, ytest, sigma2] = ...
  polyDataMake('sampling', 'sparse', 'deg', 2);
deg = 2;
addOnes = false;
Xtrain = rescaleData(degexpand(xtrain, deg, addOnes));
Xtest = rescaleData(degexpand(xtest, deg, addOnes));



%% MLE
model = linregFitSimple(Xtrain, ytrain, ...
  'preproc', struct('standardizeX', true));
[mu, v] = linregPredict(model, Xtest);

figure;
hold on;
h = plot(xtest, mu,  'k-', 'linewidth', 3);
h = plot(xtest, ytestNoisefree,  'b:', 'linewidth', 3);
h = plot(xtrain,ytrain,'ro','markersize',14,'linewidth',3);
NN = length(xtest);
ndx = 1:10:NN; % plot subset of errorbars to reduce clutter
sigma = sqrt(v);
hh=errorbar(xtest(ndx), mu(ndx), sigma(ndx));


%% Bayes
model = linregFitBayes(Xtrain, ytrain, ...
  'preproc', struct('standardizeX', true), ...
  'prior', 'gauss', 'alpha', 0.001, 'beta', 1/sigma2);
[mu, v] = linregPredictBayes(model, Xtest);

figure;
hold on;
h = plot(xtest, mu,  'k-', 'linewidth', 3);
h = plot(xtest, ytestNoisefree,  'b:', 'linewidth', 3);
h = plot(xtrain,ytrain,'ro','markersize',14,'linewidth',3);
NN = length(xtest);
ndx = 1:10:NN; % plot subset of errorbars to reduce clutter
sigma = sqrt(v);
hh=errorbar(xtest(ndx), mu(ndx), sigma(ndx));

