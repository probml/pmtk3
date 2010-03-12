function [model, bestParams, CVmu, CVse] = svmlightFitCV(X, y, varargin)
% Fit an svm using svmlight setting C and/or the kernelParam via cv. 

[C, kernelParam, kernelType, cvopts, svmopts] = process_options(varargin,...
    '-C', [], 'kernelParam', [], 'kernelType', 'rbf', 'cvopts', {}, 'svmopts', {});

if isempty(C)
    C = 1./logspace(-2, 3, 10);
end
if isempty(kernelParam)
    kernelParam = 1:10;
end

params = crossProduct(C, kernelParam); 
lossFn = @(y, yhat) mean(y ~= yhat); 
fitFn = @(X,y,param)svmlightFit(X,y,param(1),param(2),kernelType,svmopts{:}); 
[model, bestParams, CVmu, CVse] = fitCv...
    (params, fitFn, @svmlightPredict, lossFn, X, y, cvopts{:}); 


end