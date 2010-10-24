function answer = isWeaklyConnected(G)
%% Check if a directed graph is (at least) weakly connected
% A directed graph is called weakly connected if replacing all of its
% directed edges with undirected edges produces a connected (undirected)
% graph. From http://en.wikipedia.org/wiki/Connectivity_(graph_theory)
%%

% This file is from pmtk3.googlecode.com

answer = all(colvec(reachability_graph(mkSymmetric(G)))); 
end
