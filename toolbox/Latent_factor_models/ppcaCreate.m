function model = ppcaCreate(W, mu, sigma2, evals, evecs, Xproj, Xrecon)
%% Construct a ppca model

model = structure(W, mu, sigma2, evals, evecs, Xproj, Xrecon);

end