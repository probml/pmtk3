function model = laplaceCreate(mu, b)
%% Create a laplace distribution
% PMTKsimpleModel laplace
% See also laplaceFit
model = structure(mu, b); 
model.modelType = 'laplace'; 

end