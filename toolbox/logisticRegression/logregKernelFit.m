function model = logregKernelFit(X, y, lambda, kernelParam, kernelType, fitFn)

    if nargin < 3, lambda = 0;          end
    if nargin < 4, kernelParam = 1;     end
    if nargin < 5, kernelType = 'rbf';  end   
    if nargin < 5, fitFn = logregFitL2; end
    
    X = mkUnitVariance(center(X)); % important for kernel performance
    K = kernelBasis(X, X, kernelType, kernelParam);
    includeOffset = false; 
    model = fitFn(K, y, lambda, includeOffset);
    model.basis = X;
    model.kernelType = kernelType; 
    model.kernelParam = kernelParam; 
end