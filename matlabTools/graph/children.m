function C = children(G, i)
%% Return the indices of a node's children in sorted order

% This file is from matlabtools.googlecode.com

C = find(G(i, :));
end
