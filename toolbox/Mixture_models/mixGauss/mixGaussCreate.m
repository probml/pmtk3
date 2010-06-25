function model = mixGaussCreate(mu, Sigma, mixweight, K)
%% Create a mixture of Gaussian's model
% See also mixGaussFit

model = structure(mu, Sigma, mixweight, K); 
model.modelType = 'mixGauss';

end