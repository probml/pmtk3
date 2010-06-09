function S = chi2Sample(model, n)
% Sample n samples from a chi^2 distribution 
% with model.dof degrees of freedom.
dof = model.dof;
if ~isequal(length(dof), n)
    dof = repmat(dof, n);
end
S = 2.*randgamma(dof./2);
end