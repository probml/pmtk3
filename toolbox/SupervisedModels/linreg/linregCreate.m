function model = linregCreate(w, sigma2, preproc)
% Construct a linear regression object
% We include only the fields needed by linregPredict

% This file is from pmtk3.googlecode.com


if nargin < 3, preproc = preprocessorCreate(); end
model = structure(w, sigma2, preproc);
model.modelType = 'linreg'; 

end
