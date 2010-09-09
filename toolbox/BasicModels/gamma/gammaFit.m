function model = gammaFit(X)
%% Fit a gamma distribution 
% model.a is the shape, model.b is the rate

% This file is from pmtk3.googlecode.com

[a, b] = gamMOM(X); 
model = structure(a, b); 
model.modelType = 'gamma'; 
end
