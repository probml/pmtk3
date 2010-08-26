function model = invWishartCreate(Sigma, dof)
%% Construct an invWishart distribution
%PMTKdefn IW(S | \Sigma, \nu)
model = structure(Sigma, dof); 

end

