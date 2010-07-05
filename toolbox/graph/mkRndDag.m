function [G] = mkRndDag(nnodes, maxFanIn, maxFanOut)
%% Make a random directed acyclic graph

if nargin < 1, nnodes = 10; end
if nargin < 2,  maxFanIn = 2; end
if nargin < 3, maxFanOut = 3; end

G = zeros(nnodes);
for i=1:nnodes
    candidates = setdiffPMTK(1:nnodes, [i, ancestors(G, i)]);
    % candidates include everyone who is not an ancestor of the current node
    % except those potential children that already have too many parents
    candidates(arrayfun(@(c)numel(parents(G, c)), candidates) >= maxFanIn) = [];  
    nc = numel(candidates);
    if nc == 0; continue; end
    nchildren = unidrndPMTK(max(nc, maxFanOut));
    ndx = unidrndPMTK(nc, [nchildren, 1]);
    children = candidates(ndx);
    G(i, children) = 1;
end

assert(acyclic(G)); 


end