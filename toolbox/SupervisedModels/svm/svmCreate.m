function model = svmCreate(outputType, supportVectors, C, kernel, kernelParam)
%% Construct an svm model

% This file is from pmtk3.googlecode.com


model = structure(outputType, supportVectors, C, kernel, kernelParam); 
end
