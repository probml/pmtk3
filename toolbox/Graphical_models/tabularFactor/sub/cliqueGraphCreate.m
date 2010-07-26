function fg = cliqueGraphCreate(Tfac, nstates, G)
%% Construct a clique graph
% Here we assume one potential function per clique as opposed a factor
% graph representation with potential functions for nodes and edges, i.e.
% this is a representation of a graphical log linear model.
%
% Cliques, (and their associated potential functions) are represented using
% tabularFactors, (see tabularFactorCreate). 
%
% Tfac is a cell array of tabular factors
% nstates(j) is the number of states for node j
% G is the graph structure, (automatically inferred if not specified)
% G(i, j) = G(j, i) = 1 if nodes i and j live in the same clique. 
% 
%%
if nargin < 3
    G  = constructGraphFromFactors(Tfac);
end
fg = structure(Tfac, nstates, G); 
end