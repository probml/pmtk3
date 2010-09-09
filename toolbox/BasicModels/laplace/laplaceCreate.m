function model = laplaceCreate(mu, b)
%% Create a laplace distribution
%PMTKdefn laplace(x | \mu, b)
% See also laplaceFit

% This file is from pmtk3.googlecode.com

model = structure(mu, b); 
model.modelType = 'laplace'; 

end
