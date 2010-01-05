function b = acyclic(adj_mat, directed)
% ACYCLIC Returns true iff the graph has no (directed) cycles.
% b = acyclic(adj_mat, directed)

adj_mat = double(adj_mat);
if nargin < 2, directed = 1; end

% e.g., G =
% 1 -> 3
%      |
%      v
% 2 <- 4   
% In this case, 1->2 in the transitive closure, but 1 cannot get to itself.
% If G was undirected, 1 could get to itself, but this graph is not cyclic.
% So we cannot use the closure test in the undirected case.

if directed
  R = reachability_graph(adj_mat);
  b = ~any(diag(R)==1);
else
  [d, pre, post, cycle] = dfs(adj_mat,[],directed);
  b = ~cycle;    
end
