function S = invChi2Sample(model, n)
% See Gelman p580
S = model.dof*model.scale./chi2Sample(model, n);
end