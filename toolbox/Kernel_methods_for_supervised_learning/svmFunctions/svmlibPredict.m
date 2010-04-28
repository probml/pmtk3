function yhat = svmlibPredict(model, Xtest)
% PMTK interface to libsvm
% model is returned by svmlibFit
%%
% libsvm requires that only specific fields be included in model - remove
% all others;

allowed = {'Parameters', 'nr_class', 'totalSV', 'rho', 'Label', 'ProbA', ...
           'ProbB', 'nSV', 'sv_coef', 'SVs' };
remove = setdiff(fieldnames(model), allowed);
model  = rmfield(model, remove); 
%%
n = size(Xtest, 1);
evalc('yhat = svmLibMexPredict(NaN(n, 1), Xtest, model)'); 
end

