function model = discrimAnalysisCreate(type, mu, Sigma, lambda, Nclasses)
%% Construct a discriminant analysis model

% This file is from pmtk3.googlecode.com


model = structure(type, mu, Sigma, lambda, Nclasses); 
end
