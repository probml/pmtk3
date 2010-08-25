function model = mixGaussDiscreteCreate(mu, Sigma, mixweight, beta, C, K, types)
%% Construct a mixGaussDiscrete model

model = structure(mu, Sigma, mixweight, beta, C, K, types);
model.modelType = 'mixGaussDiscrete'; 


end