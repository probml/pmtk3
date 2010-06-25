function model = gaussCreate(mu, Sigma)
%% Guass constructor
model = structure(mu, Sigma); 
model.type = 'gauss';

end