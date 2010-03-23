%% Compare SVM and kernelized logreg on synthetic 2 class data in 2d
%
%% Load  Data
% Load synthetic data generated from a mixture of 2 Gaussians. Source:
% http://research.microsoft.com/~cmbishop/PRML/webdatasets/datasets.htm
%
load bishop2class
y = Y(:);

%X = mkUnitVariance(center(X));
%% Set up kernels
% We pick  hyperparameters that result in a pretty plot
lambda = 2;
rbfScale = 0.3;
gamma = 1/(2*rbfScale^2);
kernelFn = @kernelRbfSigma;
Ktrain =  kernelFn(X, X, rbfScale);

logregArgs.lambda = lambda;
logregArgs.regType = 'L2';
logregArgs.kernelFn = @kernelRbfSigma;
logregArgs.kernelParam = rbfScale; 


%[model, bestParams, cvMU, cvSigma] = svmlightFitCV(X, y); 


%% Train and test
for method=1:4
    switch method
        case 1,
            model = logregFit(X, y, logregArgs);
            fname = 'logregL2';
            predictFn = @(Xtest) logregPredict(model, Xtest);
        case 2,
            logregArgs.regType = 'L1';
            model = logregFit(X, y, logregArgs);
            SV = (abs(model.w) > 1e-5);
            fname = 'logregL1';
            predictFn = @(Xtest) logregPredict(model, Xtest);
        case 3
            C = 1/lambda;
            tic
            model = svmFit(X, y,'kernel', kernelFn,'C', C, 'kernelParam', rbfScale);
            toc
            fname = 'SVM';
            predictFn = @(Xtest) svmPredict(model, Xtest);
            yhat = svmPredict(model, X);
            trainingErrorsSVM = sum(yhat ~= convertLabelsToPM1(y))
            SVsvm = model.svi;
        case 4
            C = 1 / lambda;
            gamma = 1/(2*rbfScale^2);
            tic
            modelLight = svmFit(X, y,'C', C,'kernel', 'rbf', 'kernelParam', gamma, 'fitFn', @svmlightFit); 
            toc
            SV = modelLight.svi; 
            fname = 'SVMlight';
            predictFn = @(Xtest)svmPredict(modelLight, Xtest); 
            yhat = svmPredict(modelLight, X); 
            trainingErrorsSVMlight = sum(yhat ~= convertLabelsToPM1(y))
    end
    % Plot results
    plotDecisionBoundary(X, y, predictFn, [], [], '+x');
    if method > 1 
        plot(X(SV,1), X(SV,2), 'ok', 'linewidth', 1.5, 'markersize', 12);
    end
    title(sprintf('%s', fname))
    printPmtkFigure(sprintf('svmBinaryClassifDemo%s', fname))
end




