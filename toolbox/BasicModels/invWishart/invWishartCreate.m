function model = invWishartCreate(Sigma, dof)
%% Construct an invWishart distribution
%PMTKdefn IW(S | \Sigma, \nu)

% This file is from pmtk3.googlecode.com

model = structure(Sigma, dof); 

end

