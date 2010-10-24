function roots = graphRoots(G)
%% Return the roots in a directed graph, (nodes with no parents)

% This file is from pmtk3.googlecode.com

roots = find(~any(G, 1));
end
