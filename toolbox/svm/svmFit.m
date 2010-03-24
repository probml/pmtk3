function [model, varargout] = svmFit(X, y, varargin)
% Fit a support vector machine.
% Supports binary and multiclass classification, as well as regression,
% however not all fit functions support all problem types / kernels.
%% Cross Validation
% Cross validation is run if a range of C values and/or kernelParam values
% are specified.
%% INPUTS:
% C           - regularizer, (1/lambda)
% kernel      - string or @(X1, X2, param), e.g. 'rbf' or @kernelRbfGamma
% kernelParam - e.g. gamma in kernelRbfGamma
% fitFn       - string or @(X, y, C, kernelParam, kernel, fitOptions{:})
% fitOptions  - a cell array of fit function specific options.
%% OUTPUT:
% model is a struct with fit function specific information - this can
% be passed directly to svmPredict().
%% Fit functions:
% Defaults are selected based on this table:
%
%                 | binary | multiclass | regression | customKernel       
% svmQPclassifFit |  yes   |    no      |    no      |   yes             
% svmQPregFit     |  no    |    no      |    yes     |   yes             
% svmlightFit     |  yes   |    no      |    yes     |   no              
% svmlibFit       |  yes   |    yes     |    yes     |   no              
% svmlibLinearFit |  yes   |    yes     |    yes     |   no (only linear)
%
%% Requirements:
% svmQP*Fit         requires quadprog and thus the optimization toolbox
%
% svmlightFit       requires svmlight available here: 
%                   http://svmlight.joachims.org/
%                  
% svmlibFit         requries libsvm available here:
%                   http://www.csie.ntu.edu.tw/~cjlin/libsvm/
%                 
% svmlibLinearFit   requires liblinear available here:
%                   http://www.csie.ntu.edu.tw/~cjlin/liblinear/
%                   svmlibLinear ships with its own Matlab interface, which
%                   PMTK calls - make sure this folder is on the Matlab
%                   path. 
%
%  Make sure the binary executables are on your system 
%  path. You can use addtosystempath() to do this within Matlab.
% For example, I have made a shortcut button which executes the following
%
% addtosystempath(fullfile(pmtk3Root(), 'foreign\svmLightWindows'))
% addtosystempath(fullfile(pmtk3Root(),'foreign\liblinear-1.51\windows'))
% addtosystempath(fullfile(pmtk3Root(),'\foreign\libsvm-mat-2.9-1'))

%%
d = size(X, 2);
[   C            ,... 
    kernel       ,... 
    kernelParam  ,...
    fitFn        ,...
    fitOptions   ,...
    standardizeX ,...
    rescaleX     ,...
    cvOptions     ...
    ] = process_options(varargin, ...
    'C'          , 1     ,...
    'kernel'     , ''    ,...
    'kernelParam', 1/d   ,...
    'fitFn'      , ''    ,...
    'fitOptions' , {}    ,...
    'standardizeX', true  ,...
    'rescaleX'   , false ,...
    'cvOptions'  , {});
%%
K = nunique(y);
if K <= 2
    type = 'binary';
elseif isequal(y, round(y))
    type = 'multiclass';
else
    type = 'regression';
end

%% Select default fit function
if isempty(fitFn)
    customKernel = isa(kernel, 'function_handle');
    if customKernel
        switch type
            case 'binary'
                fitFn = @svmQPclassifFit;
            case 'regression'
                fitFn = @svmQPregFit;
            case 'multiclass'
                error('multiclass with custom kernel not yet supported');
        end
    elseif strcmpi(kernel, 'linear')
        fitFn = @svmlibLinearFit;
    else
        if isempty(kernel), kernel = 'rbf'; end
        fitFn = @svmlibFit;
    end
elseif ischar(fitFn)
    fitFn = str2func(fitFn);
end
%% Preprocess Data
if standardizeX
    X = mkUnitVariance(centerCols(X));
end
if rescaleX
    X = rescaleData(X);    
end
%%
if numel(C) > 1 || numel(kernelParam) > 1
    paramSpace = crossProduct(C, kernelParam);
    switch type
        case {'binary', 'multiclass'}
            lossFn = @(y, yhat) mean(y ~= yhat);
        case 'regression'
            lossFn = @(y, yhat) mean((y-yhat).^2);
    end
    fitcore = @(X, y, p)fitFn(X, y, p(1), p(2), kernel, fitOptions{:});
    [model, varargout{1}, varargout{2}, varargout{3}] = ...
        fitCv(paramSpace, fitcore, @svmPredict, lossFn, X, y, cvOptions{:});
else
    model = fitFn(X, y, C, kernelParam, kernel, fitOptions{:});
end

model.fitEngine = funcName(fitFn);
model.type = type;
model.standardizeX = standardizeX;
model.rescaleX = rescaleX;
end