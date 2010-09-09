function model  = studentCreate(mu, Sigma, dof)
%% Constructor for a student T distribution
%PMTKdefn T(x | \mu, \Sigma, \nu)
%%

% This file is from pmtk3.googlecode.com

model = structure(mu, Sigma, dof);
model.ndims = length(mu); 
model.modelType = 'student';


end
