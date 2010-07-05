function [postQuery, Z] = variableElimination(model, queryVars, evidence)
%% Perform sum-product variable elimination to compute sum_H p(Q, H | V=v)
% See Koller & Friedman algorithm 9.1 pg 273
% model is a struct with the following fields:
% Tfac    - a cell array of tabular factors
% G       - the graph structure: an adjacency matrix
%%
% postQuery is a tabular factor
%% Setup
if(nargin < 3)
    visVars = [];
    visVals = [];
else
    visVars = find(evidence);
    visVals = nonzeros(evidence);
end
factors = rowvec(model.Tfac);
G       = model.G;
if ~isempty(visVars)
    %% Condition on the evidence
    for i=1:numel(factors)
        localVars = intersectPMTK(factors{i}.domain, visVars);
        if isempty(localVars)
            continue;
        end
        localVals  = visVals(lookupIndices(localVars, visVars));
        factors{i} = tabularFactorSlice(factors{i}, localVars, localVals);
    end
end
nstates = cellfun(@(t)t.sizes(end), factors);
%% Find a good elimination ordering
moralG    = moralizeGraph(G); % marry parents, and make graph symmetric
ordering  = minweightElimOrder(moralG, nstates);
elim      = setdiffPMTK(ordering, [queryVars, visVars]);
%% Eliminate nuisance variables
for i=1:numel(elim)
    factors = eliminate(factors, elim(i));
end
%% Multiply and normalize
TF = tabularFactorMultiply(factors);
[postQuery, Z] = tabularFactorNormalize(TF);
end

function F = eliminate(F, v)
%% Eliminate variable v from the factors F
inscope = cellfun(@(f)any(v == f.domain), F);
psi     = tabularFactorMultiply(F(inscope));
onto    = setdiffPMTK(psi.domain, v);
tau     = tabularFactorMarginalize(psi, onto);
F       = [F(not(inscope)), {tau}];
end