function model = linregKernelFitL2(X, y, lambda, kernelParam, kernelType)
% L2 linear regression with kernel basis expansion.
if nargin < 5
    kernelType = 'rbf';
end


X = mkUnitVariance(center(X)); % important for kernel performance
K = kernelBasis(X, X, kernelType, kernelParam);
model = linregFitL2(K, y, lambda, 'QR', false);
model.basis = X;
model.kernelType = kernelType;
model.kernelParam = kernelParam;


end