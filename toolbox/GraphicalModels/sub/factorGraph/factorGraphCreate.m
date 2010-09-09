function fg = factorGraphCreate(cliques, nstates)
%% Create a factor graph
% This is a bipartite undirected graph with two types of nodes, 'round',
% and 'square'. Round nodes represent random variables, and square nodes
% represent factors. There is an edge from each variable to every factor
% that 'mentions' it. 
%
%% Input
%
% cliques     - a cell array of tabularFactors, (the cliques do not have to
%               be maximal. 
%
% nstates     - nstates(j) is the number of states for variable j
%
%% Output
%
% fg is a struct with the following fields:
%
% G          - a bipartite, undirected adjacency matrix representing the
%              node-factor connectivity. 
%
% factors    - a cell array of all of the factors, (each factor is a
%              tabularFactor: see tabularFactorCreate).
%
% nstates    - nstates(j) is the number of states variable j can take on
%
% nodeFacNdx - factors{nodeFacNdx} are node factors (pots), (i.e.
%              they 'mention' only a single variable)
%
% edgeFacNdx - factors{edgeFacNdx} are edge factors (pots) i.e. they
%              mention more than one variable.
%
% round      - indices into G indicating nodes
%
% square     - indices into G indicating factors
%
% isPairwise - true if all of the edge factors (if any) are pairwise
% 
%%

% This file is from pmtk3.googlecode.com

factors    = cliques;
nfactors   = numel(factors);  
nnodes     = length(nstates); 
round      = (1:nnodes)';
square     = (nnodes+1:nnodes+nfactors)';
sz         =  cellfun(@(f)numel(f.domain), factors); 
nodeFacNdx = find(sz == 1);
edgeFacNdx = find(sz > 1); 
isPairwise = max(sz) == 2; 


N = numel(round) + numel(square);
G = zeros(N, N); 
for i=1:numel(factors)
   dom = factors{i}.domain;
   j = square(i); 
   G(j, dom) = 1;
   G(dom, j) = 1; 
end

fg = structure(G, factors, nstates, round, square, nodeFacNdx, edgeFacNdx, isPairwise); 
end
