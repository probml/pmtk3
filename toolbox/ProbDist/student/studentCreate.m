function model  = studentCreate(mu, Sigma, dof)
% Constructor for a student T distribution
% PMTKsimpleModel student
model = structure(mu, Sigma, dof);
model.ndims = length(mu); 
model.modelType = 'student';


end