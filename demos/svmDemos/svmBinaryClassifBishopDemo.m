% Compare SVM and kernelized logreg on synthetic 2 class data in 2d

%% Load  Data
% Load synthetic data generated from a mixture of 2 Gaussians. Source:
% http://research.microsoft.com/~cmbishop/PRML/webdatasets/datasets.htm
%
load bishop2class
y = Y(:);

X = mkUnitVariance(center(X));
%% Set up kernels
lambda = 2;
rbfScale = 0.3;
gamma = 1/(2*rbfScale^2);
kernelFn = @(X1,X2) rbfKernel(X1,X2,rbfScale);
Ktrain =  kernelFn(X, X);

logregArgs.lambda = lambda;
logregArgs.regType = 'L2';
logregArgs.kernelFn = @rbfKernel;
logregArgs.kernelParam = rbfScale; 


[model, bestParams, cvMU, cvSigma] = svmlightFitCV(X, y); 


%% Train and test
for method=3:4
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
            [model, SV] = svmQPclassifFit(X, y, kernelFn,  C);
            toc
            fname = 'SVM';
            predictFn = @(Xtest) svmQPclassifPredict(model, Xtest);
            yhat = svmQPclassifPredict(model, X);
            trainingErrorsSVM = sum(yhat ~= convertLabelsToPM1(y))
            SVsvm = SV;
        case 4
            C = 1 / lambda;
            gamma = 1/(2*rbfScale^2);
            tic
            modelLight = svmlightFit(X, y, C, gamma); 
            toc
            SV = modelLight.svi; 
            fname = 'SVMlight';
            predictFn = @(Xtest)svmlightPredict(modelLight, Xtest); 
            yhat = svmlightPredict(modelLight, X); 
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




