function model = logregKernelFit(X, y, fitFn, lambda, kernelParam, kernelType)
% Fit a binary or multiclass logistic regression model using a kernel
% basis expansion of the input features and optional L1 or L2 
% regularization. See logregKerenelFitL1 and logregKernelFitL2. 
%
% X(i, :) -  is the ith case
% y       -  the labels, these will be automatically transformed into the
%            right space. 
% fitFn       -  e.g. @logregFitL1, @logregFitL2
% lambda      - regularizer value
% kernelParam - e.g Sigma if kernelType = 'rbf'
% kernelType  - type of kernel to use - see kernelBasis.m
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