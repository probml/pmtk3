function ps = parents(adj_mat, i)
% PARENTS Return the list of parents of node i
% ps = parents(adj_mat, i)

ps = find(adj_mat(:,i))';
