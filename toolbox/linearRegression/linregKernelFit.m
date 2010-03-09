function model = linregKernelFit(X, y, kernelParam, kernelType)
% Linear regression with kernel basis expansion
if nargin < 4
    kernelType = 'rbf';
end

X = mkUnitVariance(center(X)); % important for kernel performance
K = kernelBasis(X, X, kernelType, kernelParam);
model = linregFitL2(K, y, 0, 'QR', false);
model.basis = X;
model.kernelType = kernelType;
model.kernelParam = kernelParam;


end