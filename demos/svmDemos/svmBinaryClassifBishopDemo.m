% Compare SVM and kernelized logreg on synthetic 2 class data in 2d

%% Load  Data
% Load synthetic data generated from a mixture of 2 Gaussians. Source:
% http://research.microsoft.com/~cmbishop/PRML/webdatasets/datasets.htm
%
load bishop2class
y = Y(:);


%% Set up kernels
lambda = 2;
rbfScale = 0.3;
kernelFn = @(X1,X2) rbfKernel(X1,X2,rbfScale);
Ktrain =  kernelFn(X, X);


%% Train and test
for method=1:3
  switch method
    case 1,
      model = logregFitL2(Ktrain, y, lambda);
      fname = 'logregL2';
      predictFn = @(Xtest) logregPredict(model, kernelFn(Xtest, X));
    case 2,
      model = logregFitL1(Ktrain, y, lambda);
      SV = (abs(model.w) > 1e-5);
      fname = 'logregL1';
      predictFn = @(Xtest) logregPredict(model, kernelFn(Xtest, X));
    case 3
      C = 1/lambda;
      [model, SV] = svmQPclassifFit(X, y, kernelFn,  C);
      fname = 'SVM';
      predictFn = @(Xtest) svmQPclassifPredict(model, Xtest);
  end
   % Plot results
   plotDecisionBoundary(X, y, predictFn);
   if method > 1
     plot(X(SV,1), X(SV,2), 'ok', 'linewidth', 2, 'markersize', 10);
   end
   title(sprintf('%s', fname))
   printPmtkFigure(sprintf('svmBinaryClassifDemo%s', fname))
end




