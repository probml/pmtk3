function model = gammaCreate(a, b)
%% Create a Gamma distribution
% model.a is the shape, model.b is the rate
% PMTKsimpleModel gamma
model = structure(a, b); 
model.modelType = 'gamma'; 
end