function model = svmlightFit(X, y, C, kernelParam, kernelType, options)
% Call svmLight to fit a binary SVM classifier using the specified kernel,
% (rbf by default). If RBF, the kernelParam is gamma in 
% exp(-gamma ||X-X'||^2)
%
% y is automaically converted to {-1, 1}
%
% model is a structure which can be passed to svmPredict. It contains
% the filename storing the model information, and nsvecs - the number
% of support vectors.
%
% You can use the addtosystempath function to add the directory containing
% svm_learn.exe.


if nargin < 3 || isempty(C)
   cswitch = ''; 
else
   cswitch = sprintf('-c %f', C); 
end
    
if nargin < 5 || isempty(kernelType)
    kernelType = 'rbf';
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

if nunique(y) < 3
    model.problemType = 'classification';
    typeswitch = '-z c';
    y = convertLabelsToPM1(y);
else
    error('not yet implemented'); 
    model.problemType = 'regression';
    typeswitch = '-z r';
end


tmp = tempdir();
trainFile = fullfile(tmp, 'train.svm');
modelFile = fullfile(tmp, sprintf('model%s.svm', datestring()));
logFile   = fullfile(tmp, 'trainLog.svm');

%-z c       classification
%-t 2       for rbf expansion
%-g gamma   to specify rbf bandwidth
%-v 0       verbosity level 0-3 (0 is quiet)
if(nargin < 6)
    options = sprintf('%s %s %s %s -v 0', typeswitch, kswitch, kpswitch, cswitch);
end

X = mkUnitVariance(center(X));

svmlightWriteData(X, y, trainFile);
[iserror, response] = system(sprintf('svm_learn %s %s %s > %s', options, trainFile, modelFile, logFile));
if iserror
    error('There was a problem calling svmlight: %s', response); 
end
model.file = modelFile;

text = getText(modelFile);
model.nsvecs = str2double(char(strtok(text(cellfun(@(str)~isempty(str),strfind(text,'number of support vectors plus 1'))))))-1;
model.kernelType  = kernelType; 
model.kernelParam = kernelParam; 
model.C = C; 
if 1
    delete(trainFile);
    delete(logFile);
end
end