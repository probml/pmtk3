%% Posterior predictive density for Bayesian linear Regression in 1d with Polynomial Basis 
% We use a gaussian prior with fixed noise variance
% We plot the posterior predictive density, and samples from it

setSeed(0);
[xtrain, ytrain, xtest, ytestNoisefree, ytest, sigma2] = ...
  polyDataMake('sampling', 'sparse', 'deg', 2);
deg = 2;
addOnes = false;
Xtrain = degexpand(xtrain, deg, addOnes);
Xtest = degexpand(xtest, deg, addOnes);

%% MLE
model = linregFit(Xtrain, ytrain); 
[mu, v] = linregPredict(model, Xtest);

figure;
hold on;
h = plot(xtest, mu,  'k-', 'linewidth', 3);
h = plot(xtest, ytestNoisefree,  'b:', 'linewidth', 3);
h = plot(xtrain,ytrain,'ro','markersize',14,'linewidth',3);
NN = length(xtest);
ndx = 1:5:NN; % plot subset of errorbars to reduce clutter
sigma = sqrt(v);
hh=errorbar(xtest(ndx), mu(ndx), sigma(ndx));
title('mle');

%% Bayes
model = linregFitBayes(Xtrain, ytrain, ...
  'prior', 'gauss', 'alpha', 0.001, 'beta', 1/sigma2);
[mu, v] = linregPredictBayes(model, Xtest);
figure;
hold on;
plot(xtest, mu,  'k-', 'linewidth', 3, 'displayname', 'prediction');
plot(xtest, ytestNoisefree,  'b:', 'linewidth', 3, 'displayname', 'truth');
plot(xtrain,ytrain, 'ro', 'markersize', 14, 'linewidth', 3, ...
    'displayname', 'training data');
NN = length(xtest);
ndx = 1:5:NN; % plot subset of errorbars to reduce clutter
sigma = sqrt(v);
legend('location', 'northwest'); 
hh=errorbar(xtest(ndx), mu(ndx), sigma(ndx));
title('bayes (known variance)');

