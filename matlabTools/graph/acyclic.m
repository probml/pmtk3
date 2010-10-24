function b = acyclic(adj_mat, directed)
% ACYCLIC Returns true iff the graph has no (directed) cycles.
% b = acyclic(adj_mat, directed)

% This file is from pmtk3.googlecode.com


if nargin < 2, directed = 1; end

if directed
  % uses biotoolbox, or constructs reachability graph
  b = pmtkGraphIsDag(adj_mat);
else
  adj_mat = double(adj_mat);
  R = reachability_graph(adj_mat);
  b = ~any(diag(R)==1);
  %[d, pre, post, cycle] = dfs(adj_mat,[],directed);
  %b = ~cycle;
end

end
