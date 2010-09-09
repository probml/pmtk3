function model = generativeClassifierCreate(classConditionals, classPrior)
%% Construct a generative classifier model

% This file is from pmtk3.googlecode.com


model.classConditionals = classConditionals; 
model.prior = classPrior; 
model.modelType = 'generativeClassifier';


end
