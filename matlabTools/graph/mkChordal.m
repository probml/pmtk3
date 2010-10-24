function [G, fill_ins] = mkChordal(G, order)
% Eliminate nodes in specified order, and ensure uneliminated
% neighbors are fully connected by adding edges if necessary
%
% fill_ins(i,j) = 1 iff we add a fill-in arc between i and j.
% PMTKmodified Matt Dunham

% This file is from pmtk3.googlecode.com


MG = G;
n = length(G);
eliminated = false(1, n);
for i=1:n
    G = setdiag(G, 0); 
    u = order(i);
    nodes = false(1, n); 
    nodes([find(G(u, :)) find(G(:, u))']) = true; 
    nodes = nodes & ~eliminated; 
    nodes(u) = true; 
    G(nodes, nodes) = 1; 
    eliminated(u) = true; 
    
    %U = find(~eliminated); % uneliminated
    %nodes = intersectPMTK(neighbors(G, u), U); % look up neighbors in the partially filled-in graph
    %nodes = unionPMTK(nodes, u); % the clique will always contain at least u
    %G(nodes, nodes) = 1; % make them all connected to each other
    %G = setdiag(G, 0);
    %eliminated(u) = true;
end
if nargout > 1
    fill_ins = sparse(triu(max(0, G - MG), 1));
end
end

