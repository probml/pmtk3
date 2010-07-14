function [logZ, postQuery] = variableElimination(model, queryVars)
%% Sum-product variable elimination
% model is a struct with the following fields:
% Tfac    - a cell array of tabular factors
% G       - the graph structure: an adjacency matrix
%%
% postQuery is a tabular factor
% logZ is the log of the partition sum
%% Handle multiple queries 
% (note it is much more efficient to use jtree for multiple queries)
if iscell(queryVars)
   [logZ, postQuery] = cellfun(@(q)variableElimination(model, q), ...
                       queryVars, 'UniformOutput', false);
    postQuery = colvec(postQuery); 
    logZ      = logZ{1}; % all the same
    if numel(postQuery) == 1
        postQuery = postQuery{1};  
    end
    return
end
%% Setup
factors  = rowvec(model.Tfac);
G        = model.G;
nstates  = cellfun(@(t)t.sizes(end), factors);
%% Find a good elimination ordering
moralG   = moralizeGraph(G); % marry parents, and make graph symmetric
ordering = minweightElimOrder(moralG, nstates);
elim     = setdiffPMTK(ordering, queryVars);
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
Fs      = F(inscope); 
if isempty(Fs)
    return
end
psi     = tabularFactorMultiply(Fs);
onto    = setdiffPMTK(psi.domain, v);
tau     = tabularFactorMarginalize(psi, onto);
F       = [F(not(inscope)), {tau}];
end