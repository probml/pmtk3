function [model, lambdaStar, mu, se] = logregKernelFitCV...
   (X, y, regularizerFn, lambdaRange, kernelParamRange, kernelType, nfolds)
    
    if nargin < 3, regularizerFn = @penalizedL2; end
    if nargin < 4, 
        lambdaRange = [0, logspace(-2.5, 0, 5), ...
                          logspace(0.1, 1.5, 10), ...
                          logspace(1.6, 2.5, 4)];
    end
    if nargin < 5, kernelParamRange = linspace(0.5, 12, 10); end
    if nargin < 6, kernelType       = 'rbf';                 end
    if nargin < 7, nfolds           = 5;                     end
    
    Nclasses = numel(unique(y)); 
    if Nclasses < 3, newSupport = [-1, 1]; 
    else             newSupport = 1:Nclasses; 
    end
    [y, support] = setSupport(newSupport); 
    parameterSpace = makeModelSpace(lambdaRange, kernelParamRange);
    %%    
    coreFitFn = @(X, y, lambda, includeOffset)...
       logregFitCore(X, y, lambda, includeOffset, regularizerFn, Nclasses);    
    %%
    fitFn = @(X, y, params)logregKernelFit...
       (X, y, coreFitFn, params{1}{1}, params{1}{2}, kernelType);
    %%
    lossFn = @(yhat, ytest)mean(yhat ~= ytest); 
    %%
    [model, lambdaStar, mu, se] = ...
        fitCv(parameterSpace, fitFn, @logregPredict, lossFn, X, y, nfolds);
    %%
    model.ySupport = support; 
end



% #test
% load crabs
% [model, paramStar, mu, se] = logregKernelFitCV(Xtrain, ytrain)
% yhat = logregPredict(model, Xtest)
% nerrors = sum(yhat ~= ytest)
% assert(nerrors == 1)

