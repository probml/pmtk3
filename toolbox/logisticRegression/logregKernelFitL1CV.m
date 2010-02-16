function [model, lambdaStar, mu, se] = logregKernelFitL1CV...
        (X, y, lambdaRange, kernelParamRange, kernelType, nfolds)
    
    
    defaultLambdaRange = [0, logspace(-2.5, 2.5, 8)];
    defaultKernelParamRange = linspace(0.5, 12, 5);
    switch nargin 
        case 2, args = {defaultLambdaRange, defaultKernelParamRange};
        case 3, args = {lambdaRange, defaultKernelParamRange};
        case 4, args = {lambdaRange, kernelParamRange};
        case 5, args = {lambdaRange, kernelParamRange, kernelType};
        case 6, args = {lambdaRange, kernelParamRange, kernelType, nfolds};
    end
    [model, lambdaStar, mu, se] = logregKernelFitCV(X, y, @penalizedL1, args{:}); 
end


