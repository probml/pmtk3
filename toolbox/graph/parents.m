function ps = parents(G, i)
%% Return the list of parents of node i
ps = find(G(:, i))';
end