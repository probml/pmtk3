function b = pmtkGraphIsDag(adj_mat)
% Returns true iff the graph has no directed cycles.

% This file is from pmtk3.googlecode.com


if bioinfoToolboxInstalled()
    b = graphisdag(sparse(adj_mat));
else
    adj_mat = double(adj_mat);
    R = reachability_graph(adj_mat);
    b = ~any(diag(R)==1);
end
