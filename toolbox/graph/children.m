function C = children(G, i)
%% Return the indices of a node's children in sorted order
C = find(G(i, :));
end