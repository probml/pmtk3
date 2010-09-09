function model = gaussInvWishartCreate(mu, Sigma, dof, k)
%% Construct a gaussInvWishart distribution
%PMTKdefn NIW(m, S | \mu, \Sigma, \nu, \kappa)

% This file is from pmtk3.googlecode.com

model = structure(mu, Sigma, dof, k); 


end
