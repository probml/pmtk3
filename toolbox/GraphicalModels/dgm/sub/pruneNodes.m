function [Gpruned, pruned, remaining] = pruneNodes(G, query, observed)
%% Remove all nodes from dag G that are conditionally independent of query | observed

% This file is from pmtk3.googlecode.com


allnodes = 1:size(G, 1); 
hidden = setdiffPMTK(allnodes, [query, observed]); 
pruned = hidden(isCondInd(G, hidden, query, observed)); 
remaining = setdiffPMTK(allnodes, pruned); 
Gpruned = G; 
Gpruned(pruned, :) = [];
Gpruned(:, pruned) = []; 



end

