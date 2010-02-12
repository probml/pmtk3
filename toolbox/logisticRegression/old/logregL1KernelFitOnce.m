function model = logregL1KernelFitOnce(X, y, lambda, kernelParam, kernelType)

    if nargin < 5, kernelType = 'rbf'; end   
    X = mkUnitVariance(center(X)); % important for kernel performance
    K = kernelBasis(X, X, kernelType, kernelParam);
    includeOffset = false; 
    model = logregL1Fit(K, y, lambda, includeOffset);
    model.basis = X;
    model.kernelType = kernelType; 
    model.kernelParam = kernelParam; 
 
end