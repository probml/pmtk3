function model = logregKernelFitL2(X, y, lambda, kernelParam, kernelType)

    if nargin < 4, kernelParam = 1;     end
    if nargin < 5, kernelType  = 'rbf'; end   
    model = logregKernelFit(X, y, lambda, kernelParam, kernelType, @logregFitL2);
    
end