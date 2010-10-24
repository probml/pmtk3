function answer = isTopoOrdered(G)
%% Return true iff the directed graph G is topologically ordered
% that is j < k iff node j is not a child of node k. 

% This file is from pmtk3.googlecode.com

answer = false; 
nnodes = size(G, 1); 
for i=2:nnodes
    if any(children(G, i) <= i); 
        return; 
    end
end
answer = true; 
end
