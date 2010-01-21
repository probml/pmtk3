%% Multi-class Logistic Regression 
% with basis function expansion. This is a simplification of
% logregMultinomKernelMinfuncDemo
%% Setup Data
rand('state', 0); randn('state', 0); %#ok
nClasses = 5;
nInstances = 100;
nVars = 2;
[X, y] = makeData('multinomialNonlinear', nInstances, nVars, nClasses);
%% Settings
lambda = 1e-2;
addOnes = false;
polyOrder = 2;
rbfScale = 1;
%% Linear
wLinear = logregMultiL2Fit(X, y, lambda, addOnes, nClasses);
%% Polynomial
Kpoly = kernelPoly(X,X,polyOrder);
wPoly = logregMultiL2Fit(Kpoly, y, lambda, addOnes, nClasses);
%% RBF
Krbf = rbfKernel(X, X, rbfScale); 
wRBF = logregMultiL2Fit(Krbf, y, lambda, addOnes, nClasses);
%% Compute training errors
[yhat, prob] = logregMultiPredict(X, wLinear, addOnes); %#ok
trainErr_linear = mean(y~=yhat);
fprintf('Training error with raw features: %2.f%%\n', trainErr_linear*100);

[yhat, prob] = logregMultiPredict(Kpoly, wPoly, addOnes); %#ok
trainErr_poly = mean(y~=yhat);
fprintf('Training error using a polynomial kernal of degree %d: %2.f%%\n', polyOrder,  trainErr_poly*100);

[yhat, prob] = logregMultiPredict(Krbf, wRBF, addOnes);
trainErr_rbf = mean(y~=yhat);
fprintf('Training error using an RBF kernel with scale %d: %2.f%%\n', rbfScale, trainErr_rbf*100);
%% Plot decision boundaries
plotDecisionBoundary(X, y, @(X)logregMultiPredict(X, wLinear, addOnes));
title('Linear Multinomial Logistic Regression');

predictFcn = @(Xtest) logregMultiPredict(kernelPoly(Xtest, X, polyOrder), wPoly, addOnes); 
plotDecisionBoundary(X, y, predictFcn);
title('Kernel-Poly Multinomial Logistic Regression');

predictFcn = @(Xtest) logregMultiPredict(rbfKernel(Xtest, X, rbfScale), wRBF, addOnes); 
plotDecisionBoundary(X, y, predictFcn);
title('Kernel-RBF Multinomial Logistic Regression');

