function order = bestFirstElimOrder(G, node_sizes, stage)
% Greedily search for an optimal elimination order.
%
% Find an order in which to eliminate nodes from the graph in such a way as
% to try and minimize the weight of the resulting triangulated graph.  The
% weight of a graph is the sum of the weights of each of its cliques; the
% weight of a clique is the product of the weights of each of its members;
% the weight of a node is the number of values it can take on.
%
% Since this is an NP-hard problem, we use the following greedy heuristic:
% at each step, eliminate that node which will result in the addition of
% the least number of fill-in edges, breaking ties by choosing the node
% that induces the lighest clique. For details, see - Kjaerulff,
% "Triangulation of graphs -- algorithms giving small total state space",
%      Univ. Aalborg tech report, 1990 (www.cs.auc.dk/~uk)
% - C. Huang and A. Darwiche, "Inference in Belief Networks: A procedural
% guide",
%      Intl. J. Approx. Reasoning, 11, 1994
%

% This file is from pmtk3.googlecode.com


% Warning: This code is pretty old and could probably be made faster.

n = length(G);
if nargin < 3
    stage = { 1:n }; 
end % no constraints

% For long DBNs, it may be useful to eliminate all the nodes in slice t
% before slice t+1. This will ensure that the jtree has a repeating
% structure (at least away from both edges). This is why we have stages.
% See the discussion of splicing jtrees on p68 of Geoff Zweig's PhD thesis,
% Dept. Comp. Sci., UC Berkeley, 1998. This constraint can increase the
% clique size significantly.

MG = G; %
uneliminated = ones(1, n);
order = zeros(1, n);
t = 1;  % Counts which time slice we are on
for i=1:n
    U = find(uneliminated);
    valid = intersectPMTK(U, stage{t});
    % Choose the best node from the set of valid candidates
    min_fill = zeros(1, length(valid));
    min_weight = zeros(1, length(valid));
    for j=1:length(valid)
        k = valid(j);
        nbrs = intersectPMTK(neighbors(G, k), U);
        l = length(nbrs);
        M = MG(nbrs,nbrs);
        min_fill(j) = l^2 - sum(M(:)); % num. added edges
        min_weight(j) = prod(node_sizes([k nbrs])); % weight of clique
    end
    lightest_nbrs = find(min_weight==min(min_weight));
    % break ties using min-fill heuristic
    best_nbr_ndx = argmin(min_fill(lightest_nbrs));
    j = lightest_nbrs(best_nbr_ndx); % we will eliminate the j'th element of valid
    k = valid(j);
    uneliminated(k) = 0;
    order(i) = k;
    ns = intersectPMTK(neighbors(G, k), U);
    if ~isempty(ns)
        G(ns,ns) = 1;
        G = setdiag(G,0);
    end
    if ~any(logical(uneliminated(stage{t}))) % are we allowed to the next slice?
        t = t + 1;
    end
end
