function model = logregKernelFitL1(X, y, lambda, kernelParam, kernelType)

    switch nargin
        case 2, args = {};
        case 3, args = {lambda};
        case 4, args = {lambda, kernelParam};
        case 5, args = {lambda, kernelParam, kernelType};
    end
    model = logregKernelFit(X, y, args{:}, @logregFitL1);
    
end