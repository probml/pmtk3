function roots = graphRoots(G)
%% Return the roots in a directed graph, (nodes with no parents)
roots = find(~any(G, 1));
end