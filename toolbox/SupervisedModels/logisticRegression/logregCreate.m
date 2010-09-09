function model = logregCreate(w, preproc, ySupport)
%% Construct a logreg model
% We just included the fields needed by logregPredict

% This file is from pmtk3.googlecode.com


model = structure(w,  preproc, ySupport); 
model.modelType = 'logreg';
if numel(ySupport)==2
  model.binary = true;
end

end
