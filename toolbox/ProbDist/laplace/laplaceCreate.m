function model = laplaceCreate(mu, b)
%% Create a laplace distribution
% See also laplaceFit
model = structure(mu, b); 
model.modelType = 'laplace'; 

end