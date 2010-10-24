function n = nedges(G, isdirected)
%% Return the number of edges in the graph G
% does not inlcude self loops

% This file is from pmtk3.googlecode.com

G = setdiag(G, 0); 
if isdirected
    n = sum(G(:)); 
else
    n = sum(colvec(triu(G))); 
end
end
