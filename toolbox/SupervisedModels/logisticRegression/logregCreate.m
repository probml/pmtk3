function model = logregCreate(w, preproc, ySupport)
%% Construct a logreg model
% We just included the fields needed by logregPredict

model = structure(w,  preproc, ySupport); 
model.modelType = 'logreg';


end