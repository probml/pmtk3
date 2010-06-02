function [postQuery, Z] = variableElimination(model, queryVars, visVars, visVals)
%% Perform sum-product variable elimination to compute sum_H p(Q, H | V=v)
% See Koller & Friedman algorithm 9.1 pg 273
% model is a struct with the following fields:
% Tfac    - a cell array of tabular factors
% G       - the graph structure: an adjacency matrix
% domain  - the global domain
%%
% postQuery is a tabular factor
%% Setup
if(nargin < 4)
    visVars = [];
    visVals = [];
end
factors      = rowvec(model.Tfac);
G            = model.G;
globalDomain = model.domain;
nstates      = cellfun(@(t)t.sizes(end), factors);
%% Find a good elimination ordering
moralG    = moralizeGraph(G); % marry parents, and make graph symmetric 
ordering  = globalDomain(bestFirstElimOrder(moralG, nstates));
hiddenNdx = argout(2, @setdiff, ordering, union(queryVars, visVars));
elim      = ordering(sort(hiddenNdx));
%% Condition on the evidence
for i=1:numel(factors)
    localVars = intersect(factors{i}.domain, visVars);
    if isempty(localVars)
        continue;
    end
    localVals  = visVals(lookupIndices(localVars, visVars));
    factors{i} = tabularFactorSlice(factors{i}, localVars, localVals);
end
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
inscope = cellfun(@(f)ismember(v, f.domain), F); 
psi     = tabularFactorMultiply(F(inscope)); 
onto    = setdiff(psi.domain, v); 
tau     = tabularFactorMarginalize(psi, onto); 
F       = [F(not(inscope)), {tau}];
end
