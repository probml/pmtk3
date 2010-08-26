function model = probitRegCreate(w, lambda, preproc)
%% Construct a probitReg model


model = structure(w, lambda, preproc); 
model.modelType = 'probitReg'; 



end