function model = smlrCreate(w, preproc)
%% Construct a sparse multinomial logistic regression model

% This file is from pmtk3.googlecode.com


model = structure(w, preproc); 
model.modelType = 'smlr';
end
