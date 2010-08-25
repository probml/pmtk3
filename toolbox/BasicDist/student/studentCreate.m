function model  = studentCreate(mu, Sigma, dof)
% Constructor for a student T distribution
model = structure(mu, Sigma, dof);
model.ndims = length(mu); 
model.modelType = 'student';


end