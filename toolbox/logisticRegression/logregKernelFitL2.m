function model = logregKernelFitL2(X, y, lambda, kernelParam, kernelType)
% Fit a binary or multiclass logistic regression model using a kernel
% basis expansion of the input features and optional L2 
% regularization.
%
% X(i, :) -  is the ith case
% y       -  the labels, these will be automatically transformed into the
%            right space. 
% fitFn       -  e.g. @logregFitL1, @logregFitL2
% lambda      - L2 regularizer value
% kernelParam - e.g Sigma if kernelType = 'rbf'
% kernelType  - type of kernel to use - see kernelBasis.m
    switch nargin
        case 2, args = {};
        case 3, args = {lambda};
        case 4, args = {lambda, kernelParam};
        case 5, args = {lambda, kernelParam, kernelType};
    end
    model = logregKernelFit(X, y, @logregFitL2, args{:});
end