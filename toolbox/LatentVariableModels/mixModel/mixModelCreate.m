function model = mixModelCreate(cpd, type, nmix, mixWeight, mixPrior)
%% Create a mixture models
% cpd is a conditional probability distribution, see e.g.
% condGaussCpdCreate, condDiscreteProdCpdCreate, condStudentCpdCreate.
% type is one of 'gauss', 'student', 'discrete'
% 
%% 

% This file is from pmtk3.googlecode.com

if nargin < 5
    mixPrior = ones(1, nmix); 
end
model = structure(cpd, type, nmix, mixWeight, mixPrior);
model.mixPriorFn  = @(m)log(m.mixWeight(:))'*(m.mixPrior(:)-1);
end