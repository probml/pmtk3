function model = laplaceCreate(mu, b)
%% Create a laplace distribution
%PMTKdefn laplace(x | \mu, b)
% See also laplaceFit
model = structure(mu, b); 
model.modelType = 'laplace'; 

end