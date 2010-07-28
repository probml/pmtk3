function model = gammaFit(X)
%% Fit a gamma distribution 
% model.a is the shape, model.b is the rate
% PMTKsimpleModel gamma
[a, b] = gamMOM(X); 
model = structure(a, b); 
model.modelType = 'gamma'; 
end