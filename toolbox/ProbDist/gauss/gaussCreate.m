function model = gaussCreate(mu, Sigma)
%% Guass constructor
% PMTKsimpleModel gauss
model = structure(mu, Sigma); 
model.modelType = 'gauss';

end