function cg = cliqueGraphCreate(Tfac, nstates, G)
%% Construct a clique (a.k.a. cluster) graph
% This is used as as the input to many inference algorithms such 
% as variable elimination, junction tree, and belief propagation. 
%
% Here we assume one potential function per clique as opposed a factor
% graph representation, (see factorGraphCreate) with potential functions
% for nodes and edges.
%
% Note, this is not a junction tree, i.e. it does not necessarily satisfy
% RIP, nor is it necessarily a tree: see jtreeCreate.
%
% Further, the cliques are not necessarily maximal, (thus clusterGraph
% might be a better name).
%
% Cliques, (and their associated potential functions) are represented using
% tabularFactors, (see tabularFactorCreate).
%
%% Inputs
% Tfac              - cell array of tabular factors
% nstates(j)        - the number of states for node j
% G                 - the (node - not clique) adjacency matrix,
%                    (automatically inferred if not specified)
%
% Note G may be either directed or undirected (in contrast to factor
% graph). If G is automatically inferred, it is undirected.
%%

% This file is from pmtk3.googlecode.com

if nargin < 3
    G  = constructGraphFromFactors(Tfac);
end
cg = structure(Tfac, nstates, G);
end
