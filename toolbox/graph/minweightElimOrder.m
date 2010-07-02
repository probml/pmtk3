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

n = length(G);
if nargin < 2, nodeWeights = ones(1, n); end

uneliminated = ones(1,n);
order = zeros(1,n);
Gorig = G;
for i=1:n
    U = find(uneliminated);
    valid = U;
    % Choose the best node from the set of valid candidates
    min_fill = zeros(1,length(valid));
    min_weight = zeros(1,length(valid));
    for j=1:length(valid)
        k = valid(j);
        nbrs = intersectPMTK(neighbors(G, k), U);
        l = length(nbrs);
        M = Gorig(nbrs,nbrs);
        min_fill(j) = l^2 - sum(M(:)); % num. added edges
        min_weight(j) = sum(nodeWeights([k nbrs])); % weight of clique
    end
    lightest_nbrs = find(min_weight==min(min_weight));
    % break ties using min-fill heuristic
    best_nbr_ndx = argmin(min_fill(lightest_nbrs));
    j = lightest_nbrs(best_nbr_ndx); % we will eliminate the j'th element of valid
    %j1s = find(score1==min(score1));
    %j = j1s(argmin(score2(j1s)));
    k = valid(j);
    uneliminated(k) = 0;
    order(i) = k;
    ns = intersectPMTK(neighbors(G, k), U);
    if ~isempty(ns)
        G(ns,ns) = 1;
        G = setdiag(G,0);
    end
end

