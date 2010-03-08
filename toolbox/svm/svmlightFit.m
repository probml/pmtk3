function model = svmLightFit(X, y, sigma, options)
% Call svmLight to fit a binary SVM classifier using RBF kernel 
% 
%
% sigma is the RBF bandwidth, (ignored if options is specified)
% y is automaically converted to {-1, 1}
%
% model is a structure which can be passed to svmPredict. It contains
% the filename storing the model information, and nsvecs - the number
% of support vectors. 
%
% You can use the addtosystempath function to add the directory containing
% svm_learn.exe. 
    
    tmp = tempdir();
    trainFile = fullfile(tmp, 'train.svm');
    modelFile = fullfile(tmp, sprintf('model%s.svm', datestring())); 
    logFile   = fullfile(tmp, 'trainLog.svm');
    
    %-z c       classification
    %-t 2       for rbf expansion
    %-g sigma   to specify rbf bandwidth
    %-v 0       verbosity level 0-3 (0 is quiet)
    if(nargin < 5)
        options = sprintf('-z c -t 2 -g %f -v 0', sigma);
    end
    
    X = mkUnitVariance(center(X));
    y = canonizeLabels(y) - 1; 
    y(y==0) = -1; 
    svmWriteData(X, y, trainFile);
    systemf('svm_learn %s %s %s > %s', options, trainFile, modelFile, logFile);
    model.file = modelFile; 
    
    text = getText(modelFile); 
    model.nsvecs = str2double(char(strtok(text(cellfun(@(str)~isempty(str),strfind(text,'number of support vectors plus 1'))))))-1;
   
    if 1
       delete(trainFile);
       delete(logFile);
    end
end