% Simplification of logregMultinomKernelDemo to the binary case.
% This file is from pmtk3.googlecode.com

function logregBinaryDemo()
%% Setup Data
setSeed(0);
nClasses = 2;
nInstances = 100;
nVars = 2;
[X, y] = makeData('multinomialNonlinear', nInstances, nVars, nClasses);

%tmp = loadData('knnClassify3c'); % 500 samples from 2 classes
%X = tmp.Xtrain;
%y = tmp.ytrain;

%% Fit models
% Linear
lambda    = 1e-2;
modelLinear = logregFit(X, y, 'lambda', lambda);
% Kernelized
fitkern = @(k, p)logregFit(X, y, 'lambda', lambda, ...
    'preproc', struct('kernelFn', @(X1, X2)k(X1, X2, p))); 
% Polynomial
polyOrder = 2;
modelPoly = fitkern(@kernelPoly, polyOrder); 
% RBF
rbfScale  = 0.1;
modelRBF = fitkern(@kernelRbfSigma, rbfScale); 
% KNN
Ks = [10];
modelKNN = {};
for K=Ks(:)'
    modelKNN{K} = knnFit(X, y, K); 
end
  
%% Compute training errors
[yhat, prob] = logregPredict(modelLinear, X); %#ok
trainErr_linear = mean(y~=yhat);
fprintf('Training error with raw features: %2.f%%\n', trainErr_linear*100);

[yhat, prob] = logregPredict(modelPoly, X); %#ok
trainErr_poly = mean(y~=yhat);
fprintf('Training error using a polynomial kernal of degree %d: %2.f%%\n', polyOrder,  trainErr_poly*100);

[yhat, prob] = logregPredict(modelRBF, X);
trainErr_rbf = mean(y~=yhat);
fprintf('Training error using an RBF kernel with scale %2.f: %2.f%%\n', rbfScale, trainErr_rbf*100);

for K=Ks(:)'
[yhat, prob] = knnPredict(modelKNN{K}, X);
trainErr_knn = mean(y~=yhat);
fprintf('Training error using KNN with K=%d: %2.f%%\n', K, trainErr_knn*100);
end


%% Plot decision boundaries
% Linear
predictFcn = @(Xtest) logregPredict(modelLinear, Xtest);
plotDecisionBoundary(X, y, predictFcn);
title('Linear Logistic Regression');
printPmtkFigure('logregBinaryLinearBoundary');

plotClassProb(X, y, predictFcn);
title('Prob class 1');
printPmtkFigure('logregBinaryLinearProbClass1');

% Quadratic
predictFcn = @(Xtest) logregPredict(modelPoly, Xtest); 
plotDecisionBoundary(X, y, predictFcn);
title('Quadratic Logistic Regression');
printPmtkFigure('logregBinaryQuadBoundary');

plotClassProb(X, y, predictFcn);
title('Prob class 1'); 
printPmtkFigure('logregBinaryQuadProbClass1');

% RBF
predictFcn = @(Xtest) logregPredict(modelRBF, Xtest); 
plotDecisionBoundary(X, y, predictFcn);
title('RBF Logistic Regression');
printPmtkFigure('logregBinaryRbfBoundary');

plotClassProb(X, y, predictFcn);
title('Prob class 1'); 
printPmtkFigure('logregBinaryRbfProbClass1');


%KNN
for K=Ks(:)'
predictFcn = @(Xtest) knnPredict(modelKNN{K}, Xtest); 
plotDecisionBoundary(X, y, predictFcn);
title(sprintf('KNN with K=%d', K));
printPmtkFigure(sprintf('logregBinaryKNN%dBoundary', K));

plotClassProb(X, y, predictFcn);
title(sprintf('KNN with K=%d, Prob class 1', K));
printPmtkFigure(sprintf('logregBinaryKNN%dProbClass1', K));
end

end
