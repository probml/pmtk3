function logregXorDemo()
% Apply L2 Logistic Regression to the XOR problem and show how an RBF 
% expansion of the features 'solves' it, while using raw features does
% not. 
    
    [X, y] = createXORdata();
    lambda = 1e-2;
    %% Linear Features
    model = logregFit(X, y, 'lambda', lambda);
    yhat = logregPredict(model, X);
    errorRate = mean(yhat ~= y);
    fprintf('Error rate using raw features: %2.f%%\n', 100*errorRate);
    plotDecisionBoundary(X, y, @(X)logregPredict(model, X));
    printPmtkFigure('logregXorLinear')
    
    %% RBF Features
    rbfScale = 1;
    model = logregFit(X, y, 'lambda', lambda, 'kernelFn', @kernelRbfSigma, 'kernelParam', rbfScale);
    yhat = logregPredict(model, X);
    errorRate = mean(yhat ~= y);
    fprintf('Error rate using RBF features: %2.f%%\n', 100*errorRate);
    predictFcn = @(Xtest)logregPredict(model, Xtest); 
    plotDecisionBoundary(X, y, predictFcn);
    printPmtkFigure('logregXorRbf')
    
end