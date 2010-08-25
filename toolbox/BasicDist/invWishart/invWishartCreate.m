function model = invWishartCreate(Sigma, dof)
%% Construct an invWishart distribution
%PMTKdefn IW(S | \Sigma, \dof)
model = structure(Sigma, dof); 

end

