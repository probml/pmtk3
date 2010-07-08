function [logZ, postQuery] = variableElimination(model, queryVars)
%% Sum-product variable elimination
% model is a struct with the following fields:
% Tfac    - a cell array of tabular factors
% G       - the graph structure: an adjacency matrix
%%
% postQuery is a tabular factor
% logZ    - the log normalization constant
%% Setup
factors  = rowvec(model.Tfac);
G        = model.G;
nstates  = cellfun(@(t)t.sizes(end), factors);
%% Find a good elimination ordering
moralG   = moralizeGraph(G); % marry parents, and make graph symmetric
ordering = minweightElimOrder(moralG, nstates);
elim     = setdiffPMTK(ordering, [queryVars, visVars]);
%% Eliminate nuisance variables
for i=1:numel(elim)
    factors = eliminate(factors, elim(i));
end
%% Multiply and normalize
TF             = tabularFactorMultiply(factors);
[postQuery, Z] = tabularFactorNormalize(TF);
logZ           = log(Z + eps);
end

function F = eliminate(F, v)
%% Eliminate variable v from the factors F
inscope = cellfun(@(f)any(v == f.domain), F);
psi     = tabularFactorMultiply(F(inscope));
onto    = setdiffPMTK(psi.domain, v);
tau     = tabularFactorMarginalize(psi, onto);
F       = [F(not(inscope)), {tau}];
end