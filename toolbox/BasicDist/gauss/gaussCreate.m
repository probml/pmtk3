function model = gaussCreate(mu, Sigma)
%% Guass constructor
%PMTKdefn \N(x | \mu, \Sigma); 
model = structure(mu, Sigma); 
model.modelType = 'gauss';

end