function model = discrimAnalysisCreate(type, mu, Sigma, lambda, Nclasses)
%% Construct a discriminant analysis model

model = structure(type, mu, Sigma, lambda, Nclasses); 
end