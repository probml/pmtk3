function model = rvmCreate(likelihood, w, gamma, hyperParams, preproc)
%% Construct an rvm model

% This file is from pmtk3.googlecode.com

switch lower(likelihood)
    case 'gaussian'
        outputType = 'regression';
    case 'bernoulli'
        outputType = 'binary'; 
end
model = structure(likelihood, w, gamma, hyperParams, preproc, outputType); 

end
