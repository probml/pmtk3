function model = svmCreate(outputType, supportVectors, C, kernel, kernelParam)
%% Construct an svm model

model = structure(outputType, supportVectors, C, kernel, kernelParam); 
end