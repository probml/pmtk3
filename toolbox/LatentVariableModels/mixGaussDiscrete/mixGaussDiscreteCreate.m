function model = mixGaussDiscreteCreate(mu, Sigma, mixweight, beta, C, K, types)
%% Construct a mixGaussDiscrete model

% This file is from pmtk3.googlecode.com


model = structure(mu, Sigma, mixweight, beta, C, K, types);
model.modelType = 'mixGaussDiscrete'; 


end
