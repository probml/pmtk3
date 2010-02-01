function model  = studentDist(mu, Sigma, dof)
% Constructor for a student T distribution

model = struct('mu',mu, 'Sigma',Sigma, 'dof', dof, ...
  'type', 'student', 'ndims', length(mu));
