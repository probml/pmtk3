function [model, varargout] = svmFit(X, y, varargin)
% Fit a support vector machine.
% Supports binary and multiclass classification, as well as regression.
% This is a wrapper to SVMlight, libsvm, liblinear
% and our own QP-based SVM code (which requires the quadprog function 
% in the optimization toolbox).
% See svmFitTest for examples of how to use this function.
%
%% INPUTS:
% C           - regularizer, (1/lambda)
% kernel      - string or @(X1, X2, param), e.g. 'rbf' or @kernelRbfGamma
% kernelParam - e.g. gamma in kernelRbfGamma
% fitFn       - string or @(X, y, C, kernelParam, kernel, fitOptions{:})
% fitOptions  - a cell array of fit function specific options.
% cvOptions   - used to control the cross valudation estimate
%               of C and/or kernel params (if these are vectors)
%
% libsvm's grid.py  uses the following range to CV over
% for C and gamma (log base 2)
% c_begin, c_end, c_step = -5,  15, 2
% g_begin, g_end, g_step =  3, -15, -2
% See also svmModsel
%
%% OUTPUT:
% model is a struct with fit function specific information - this can
% be passed directly to svmPredict().
%% Fit functions:
% The following table shows the functionality of the different fitting
% methods. The fastest suitable method is automatically chosen,
% unless you specify one by hand. Specifically, if the kernel is a function
% handle (custom kernel), it uses our QP code. If it is a string (i.e., the
% name of a standard kernel), it uses libsvm
% or liblinear (svmlight is never called by default).
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

% This file is from pmtk3.googlecode.com

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
    'rescaleX'   , false   ,...
    'cvOptions'  , {});
%%
K = nunique(y);
if K <= 2
    type = 'binary';
    [y, ySupport] = setSupport(y, [-1 1]);
    outputType = 'binary';
elseif isequal(y, round(y))
    type = 'multiclass';
    [y, ySupport] = setSupport(y, 1:K);
     outputType = 'multiclass';
else
    type = 'regression';
    ySupport = [];
    outputType = 'regression';
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
    [X, minx, rangex] = rescaleData(X, -1, 1);    
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
    C = varargout{1}(1); 
    kernelParam = varargout{1}(2); 
else
    model = fitFn(X, y, C, kernelParam, kernel, fitOptions{:});
end

model.C = C;
model.kernelParam = kernelParam; 


model.fitEngine = funcName(fitFn);
model.type = type;
model.standardizeX = standardizeX;
model.rescaleX = rescaleX;
if rescaleX
    model.minx = minx;
    model.rangex = rangex;
end
model.ySupport = ySupport;
model.outputType = outputType;
model.kernel = kernel; 
%% support vectors
switch lower(model.fitEngine)
    
    case 'svmlibfit'
        
        model.supportVectors = full(model.SVs);
        model.nsvecs         = size(model.supportVectors, 1); 
        
    case 'svmliblinearfit'
        
        [model.svi, cols] = find(arrayfun(@(x)approxeq(x, 1, 0.01),... 
            abs(X*model.w' + model.bias))); %#ok need to have two outputs
        model.supportVectors = X(model.svi, :);
        model.nsvecs = numel(model.svi);
        
    case 'svmlightfit'
        
        model.supportVectors = X(model.svi, :); 
        model.nsvecs = numel(model.svi); 
        
    case {'svmqpclassiffit', 'svmqpregfit'}
        
        % nothing to do
        
end
end
