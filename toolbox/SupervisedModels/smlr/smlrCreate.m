function model = smlrCreate(w, preproc)
%% Construct a sparse multinomial logistic regression model

model = structure(w, preproc); 
model.modelType = 'smlr';
end