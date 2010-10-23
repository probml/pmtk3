function leaves = graphLeaves(G)
%% Return the leaves in a directed graph, (nodes with no children)

% This file is from matlabtools.googlecode.com

leaves = find(~any(G, 2));
end
