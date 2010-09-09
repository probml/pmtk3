function model = svmlightFit(X, y, C, kernelParam, kernelType, saveAlphas, options)
% Call svmLight to fit a binary SVM classifier using the specified kernel,
% (rbf by default). If RBF, the kernelParam is gamma in
% exp(-gamma ||X-X'||^2).
%
% Supports classification and regression. 
%
%
% model is a structure which can be passed to svmPredict. 
%
% You can use the addtosystempath function to add the directory containing
% svm_learn.exe.
%
%%

% This file is from pmtk3.googlecode.com

if nargin < 3 || isempty(C), 
    cswitch = '';
else
    cswitch = sprintf('-c %f', C);
end
if nargin < 5 || isempty(kernelType)
    kernelType = 'rbf';
end
if nargin < 6 || isempty(saveAlphas)
    saveAlphas = true;
end
if saveAlphas  % adds extra IO overhead
    alphaFile = [tempname(), 'alphas.svn'];
    saveAlphaSwitch = sprintf('-a %s', alphaFile);
else
    saveAlphaSwitch = '';
end
switch kernelType
    case 'linear'
        kswitch = '-t 0';
        kpswitch = '';
    case 'polynomial'
        kswitch = '-t 1';
        kpswitch = sprintf('-d %f', kernelParam);
    case 'rbf'
        kswitch = '-t 2';
        kpswitch = sprintf('-g %f', kernelParam);
    otherwise
        error('%s is not a supported kernelType. Valid options are ''linear'', ''polynomial'', ''rbf'', ''sigmoid''.', kernelType);
end

if isequal(y, round(y)) && nunique(y) < 3
    yformat = '%d';
    model.problemType = 'classification';
    typeswitch = '-z c';
    y = convertLabelsToPM1(y);
else
    yformat = '%f';
    model.problemType = 'regression';
    typeswitch = '-z r';
end
tmp = tempdir();
trainFile = fullfile(tmp, 'train.svm');
modelFile = fullfile(tmp, sprintf('model%s.svm', datestring()));

%-z c       classification
%-t 2       for rbf expansion
%-g gamma   to specify rbf bandwidth
%-v 0       verbosity level 0-3 (0 is quiet)
%-b 1       fit biased hyperplane
%-# 1000    max # of iterations
if(nargin < 7)
    options = sprintf('%s %s %s %s %s -v 0 -b 1 -# 1000', ...
        typeswitch, kswitch, kpswitch, cswitch, saveAlphaSwitch);
end

svmlightWriteData(X, y, trainFile, yformat);
[iserror, response] = system(sprintf('svm_learn %s %s %s', options, trainFile, modelFile));
if iserror
    error('There was a problem calling svmlight: %s', response);
end
model.file = modelFile;
model.kernelType  = kernelType;
model.kernelParam = kernelParam;
model.C = C;
model.fitOptions = options;
if saveAlphas
    alpha = str2double(getText(alphaFile));
    epsilon = C*1e-6;
    model.svi = find( alpha > epsilon );  % support vectors indices
    if strcmp(model.problemType, 'classification')
        model.alpha = alpha.*y; % undoes the multiplication done by svmlight
    else
        n = numel(y); 
        model.alpha = alpha(1:n) + alpha(n+1:2*n);
    end
end
model.fitEngine = mfilename();
end
