function model = probitRegCreate(w, lambda, preproc)
%% Construct a probitReg model

% This file is from pmtk3.googlecode.com



model = structure(w, lambda, preproc); 
model.modelType = 'probitReg'; 



end
