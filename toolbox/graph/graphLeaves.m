function leaves = graphLeaves(G)
%% Return the leaves in a directed graph, (nodes with no children)
leaves = find(~any(G, 2));
end