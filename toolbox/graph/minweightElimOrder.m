function order = minweightElimOrder(G, nodeWeights)
% Greedily find an elimination order which induces the lightest clique.
% Break ties by minimizing the number of fill-in edges.
% So if nodeWeights = zeros(1,d), this is just minfill heuristic.
%
% For details, see
% - Kjaerulff, "Triangulation of graphs -- algorithms giving small total state space",
%      Univ. Aalborg tech report, 1990 (www.cs.auc.dk/~uk)
% - C. Huang and A. Darwiche, "Inference in Belief Networks: A procedural guide",
%      Intl. J. Approx. Reasoning, 11, 1994
%
%PMTKmodified Matt Dunham (partially vectorized code)
%%
n = length(G);
if nargin < 2,
    nodeWeights = ones(1, n);
end
nodeWeights = rowvec(nodeWeights); 
U     = true(1, n);
order = zeros(1, n);
Gorig = G;
G     = logical(G);
for i=1:n
    G           = setdiag(G, false);
    candidates  = find(U);
    nbrs        = bsxfun(@and, G(U, :) | G(:, U)', U);
    ncandidates = numel(candidates);
    minFill     = zeros(1, ncandidates);
    for j=1:ncandidates
        nodes      = nbrs(j, :);
        minFill(j) = sum(sum((Gorig(nodes, nodes)))); 
    end
    minFill      = (sum(nbrs, 2).^2)' - minFill;
    minWeight    = sum(bsxfun(@times, nbrs, nodeWeights), 2)' + nodeWeights(candidates);
    lightestNbrs = find(minWeight==min(minWeight));
    bestNbrNdx   = minidx(minFill(lightestNbrs));
    k            = candidates(lightestNbrs(bestNbrNdx));
    U(k)         = false;
    order(i)     = k;
    ns           = (G(k, :) | G(:, k)') & U;
    G(ns, ns)    = true;
end