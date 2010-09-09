function model = ppcaCreate(W, mu, sigma2, evals, evecs, Xproj, Xrecon)
%% Construct a ppca model

% This file is from pmtk3.googlecode.com


model = structure(W, mu, sigma2, evals, evecs, Xproj, Xrecon);

end
