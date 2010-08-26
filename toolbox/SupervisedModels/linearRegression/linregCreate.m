function model = linregCreate(w, sigma2, lambda, likelihood, preproc)


model = structure(w, sigma2, lambda, likelihood, preproc);
model.modelType = 'linreg'; 



end