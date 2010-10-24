function G = mkRndDag(nnodes, maxFanIn, maxFanOut, sparsityFactor)
%% Make a random, directed, weakly connected, topologically ordered, acyclic graph 
%
% A directed graph is called weakly connected if replacing all of its
% directed edges with undirected edges produces a connected (undirected)
% graph. From http://en.wikipedia.org/wiki/Connectivity_(graph_theory)
%
% By topologically ordered, we mean that if j < k, then node j is not a
% child of node k. 
%
%
% sparsityFactor (poisson parameter) influences the sparsity, higher = denser
%%

% This file is from pmtk3.googlecode.com

if nargin < 1, nnodes = 10; end
if nargin < 2,  maxFanIn = 2; end
if nargin < 3, maxFanOut = 3; end
if nargin < 4, sparsityFactor = 0.1; end
G = zeros(nnodes);
for i=randperm(nnodes)
    candidates = setdiffPMTK(1:nnodes, [i, ancestors(G, i)]);
    % candidates include everyone who is not an ancestor of the current node
    % except those potential children that already have too many parents
    candidates(arrayfun(@(c)numel(parents(G, c)), candidates) >= maxFanIn) = [];  
    nc = numel(candidates);
    if nc == 0; continue; end
    %nchildren = unidrndPMTK(min(nc, maxFanOut));
    nchildren = min([nc, poissonSample(sparsityFactor, 1)+1, maxFanOut]); 
    
    
    ndx = unidrndPMTK(nc, [nchildren, 1]);
    kids = candidates(ndx);
    G(i, kids) = 1;
end

order = toposort(G);
G = G(:, order); 
G = G(order, :); 

test = true; 
if test
    assert(pmtkGraphIsDag(G));
    assert(isTopoOrdered(G)); 
    assert(isWeaklyConnected(G)); 
    for i=1:nnodes
        assert(numel(children(G, i)) <= maxFanOut); 
        assert(numel(parents(G, i)) <= maxFanIn); 
    end
end

end
