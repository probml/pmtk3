function model = gaussCreate(mu, Sigma)
%% Guass constructor
%PMTKdefn N(x | \mu, \Sigma)

% This file is from pmtk3.googlecode.com

model = structure(mu, Sigma); 
model.modelType = 'gauss';

end
