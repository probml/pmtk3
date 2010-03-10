function model = linregKernelFitL1(X, y, lambda, kernelParam, kernelType)
% L1 linear regression with kernel basis expansion.
if nargin < 5
    kernelType = 'rbf';
end

X = mkUnitVariance(center(X)); % important for kernel performance
K = kernelBasis(X, X, kernelType, kernelParam);
model = linregFitL1(K, y, lambda, 'interiorpoint', false);
model.basis = X;
model.kernelType = kernelType;
model.kernelParam = kernelParam;


end