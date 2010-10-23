function roots = graphRoots(G)
%% Return the roots in a directed graph, (nodes with no parents)

% This file is from matlabtools.googlecode.com

roots = find(~any(G, 1));
end
