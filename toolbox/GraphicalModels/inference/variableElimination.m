function [logZ, postQuery] = variableElimination(cliqueGraph, queryVars)
%% Sum-product variable elimination
% cliqueGraph is a struct with the following fields:
%   Tfac       - a cell array of tabular factors
%   G          - the graph structure: an adjacency matrix
%   nstates(j) - the number of states for node j
% queryVars is either a vector of integer indices,
%   or a cell array of such
%%
% postQuery is a tabular factor
% logZ is the log of the partition sum

%% Handle multiple queries 
% (note it is much more efficient to use jtree for multiple queries)

% This file is from pmtk3.googlecode.com

% In the special case where we query nothing (so we just
% want to compute logZ), make sure we use an array, not a cell array
if isempty(queryVars), queryVars = []; end

if iscell(queryVars)
   [logZ, postQuery] = cellfun(@(q)variableElimination(cliqueGraph, q), ...
                       queryVars, 'UniformOutput', false);
    postQuery = colvec(postQuery); 
    logZ      = logZ{1}; % all the same
    if numel(postQuery) == 1
        postQuery = postQuery{1};  
    end
    return
end
%% Setup
factors  = rowvec(cliqueGraph.Tfac);
G        = cliqueGraph.G;
nstates  = cliqueGraph.nstates; 
%% Find a good elimination ordering
moralG   = moralizeGraph(G); % marry parents, and make graph symmetric
ordering = minWeightElimOrder(moralG, nstates);
elim     = setdiffPMTK(ordering, queryVars);
%% Eliminate nuisance variables
for i=1:numel(elim)
    factors = eliminate(factors, elim(i));
end
%% Multiply and normalize
TF             = tabularFactorMultiply(factors);
TF = tabularFactorMarginalize(TF, queryVars); % put nodes in requested order 
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
