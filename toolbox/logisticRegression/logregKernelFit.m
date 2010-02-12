function model = logregKernelFit(X, y, fitFn, lambda, kernelParam, kernelType)

    if nargin < 3, fitFn = @logregFitL2; end
    if nargin < 4, lambda = 0;           end
    if nargin < 5, kernelParam = 1;      end
    if nargin < 6, kernelType = 'rbf';   end   
    
    
    X = mkUnitVariance(center(X)); % important for kernel performance
    K = kernelBasis(X, X, kernelType, kernelParam);
    includeOffset = false; 
    model = fitFn(K, y, lambda, includeOffset);
    model.basis = X;
    model.kernelType = kernelType; 
    model.kernelParam = kernelParam; 
end