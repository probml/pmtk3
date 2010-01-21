function logregXorDemo()
% Apply L2 Logistic Regression to the XOR problem and show how an RBF 
% expansion of the features 'solves' it, while using raw features does
% not. 
    
    [X, y] = createXORdata();
    Y1tok = canonizeLabels(y,0:1);
    lambda = 1e-2;
    addOnes = true;
    %% Linear Features
    model = logregL2Fit(X, Y1tok, lambda, addOnes);
    yhat = logregPredict(model, X);
    errorRate = mean(yhat ~= y);
    fprintf('Error rate using raw features: %2.f%%\n', 100*errorRate);
    plotDecisionBoundary(X, y, @(X)logregPredict(model, X));
    %% RBF Features
    rbfScale = 1;
    Krbf = rbfKernel(X, X, rbfScale); 
    model = logregL2Fit(Krbf, y, lambda, addOnes);
    yhat = logregPredict(model, Krbf);
    errorRate = mean(yhat ~= y);
    fprintf('Error rate using RBF features: %2.f%%\n', 100*errorRate);
    predictFcn = @(Xtest) logregPredict(model, rbfKernel(Xtest, X, rbfScale)); 
    plotDecisionBoundary(X, y, predictFcn);
    
    
    
    
    
end