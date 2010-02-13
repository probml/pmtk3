function [model, lambdaStar, mu, se] = logregKernelFitL1CV(X, y, lambdaRange, kernelParamRange, kernelType, nfolds)
    
    switch nargin 
        case 2, args = {};
        case 3, args = {lambdaRange};
        case 4, args = {lambdaRange, kernelParamRange};
        case 5, args = {lambdaRange, kernelParamRange, kernelType};
        case 6, args = {lambdaRange, kernelParamRange, kernelType, nfolds};
    end
    [model, lambdaStar, mu, se] = logregKernelFitCV(X, y, @penalizedL1, args{:}); 
end



%#test
% load crabs
% model = logregKernelFitL1CV(Xtrain, ytrain)
% yhat = logregPredict(model, Xtest)
% nerrors = sum(yhat ~= ytest)