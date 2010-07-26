function cg = cliqueGraphCreate(Tfac, nstates, G)
%% Construct a clique graph
% Here we assume one potential function per clique as opposed a factor
% graph representation with potential functions for nodes and edges. Note,
% this is not a junction tree, (i.e. it does not necessarily satisfy RIP) -
% see jtreeCreate. 
%
% Cliques, (and their associated potential functions) are represented using
% tabularFactors, (see tabularFactorCreate). 
%
% Tfac is a cell array of tabular factors
% nstates(j) is the number of states for node j
% G is the (node) graph structure, (automatically inferred if not specified)
%
% Note G may be either directed or undirected (in contrast to factor
% graph). If G is automatically inferred, it is undirected. 
%%
if nargin < 3
    G  = constructGraphFromFactors(Tfac);
end
cg = structure(Tfac, nstates, G); 
end