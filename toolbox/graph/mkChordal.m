function [G, fill_ins] = mkChordal(G, order)
% Eliminate nodes in specified order, and ensure uneliminated
% neighbors are fully connected by adding edges if necessary
%
% fill_ins(i,j) = 1 iff we add a fill-in arc between i and j.

MG = G;
n = length(G);
eliminated = zeros(1,n);
for i=1:n
    u = order(i);
    U = find(~eliminated); % uneliminated
    nodes = intersect(neighbors(G, u), U); % look up neighbors in the partially filled-in graph
    nodes = union(nodes, u); % the clique will always contain at least u
    G(nodes, nodes) = 1; % make them all connected to each other
    G = setdiag(G, 0);
    eliminated(u) = 1;
end

fill_ins = sparse(triu(max(0, G - MG), 1));

end


