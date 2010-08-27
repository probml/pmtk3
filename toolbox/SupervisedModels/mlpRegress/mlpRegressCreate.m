function model = mlpRegressCreate(w, sigma2, nHidden)
%% Construct a mlpRegress model


model.w  = w;
model.sigma2 = sigma2;
model.nHidden = nHidden;
model.modelType = 'mlpRegress';
 

end