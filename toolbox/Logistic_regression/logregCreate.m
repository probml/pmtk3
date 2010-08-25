function model = logregCreate(w, lambda, preproc)
%% Construct a logreg model

model = structure(w, lambda, preproc); 
model.modelType = 'logreg';


end