function model = linregCreate(w, sigma2, preproc)
% Construct a linear regression object
% We include only the fields needed by linregPredict

model = structure(w, sigma2, preproc);
model.modelType = 'linreg'; 

end