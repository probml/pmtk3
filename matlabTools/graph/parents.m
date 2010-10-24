function ps = parents(G, i)
%% Return the list of parents of node i

% This file is from pmtk3.googlecode.com

ps = find(G(:, i))';
end
