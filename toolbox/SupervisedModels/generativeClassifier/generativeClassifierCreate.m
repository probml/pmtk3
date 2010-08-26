function model = generativeClassifierCreate(classConditionals, classPrior)
%% Construct a generative classifier model

model.classConditionals = classConditionals; 
model.prior = classPrior; 
model.modelType = 'generativeClassifier';


end