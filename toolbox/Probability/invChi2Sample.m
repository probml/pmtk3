function S = invChi2Sample(model, n)
% Sample from an inverse Chi^2 distribution
% See Gelman p580
S = model.dof*model.scale./chi2Sample(model, n);
end