function ps = parents(G, i)
%% Return the list of parents of node i

% This file is from matlabtools.googlecode.com

ps = find(G(:, i))';
end
