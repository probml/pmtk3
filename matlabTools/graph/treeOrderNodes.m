function [prevNodes] = treeOrderNodes(adj, root)
% Compute node ordering, parents before children, in a rooted directed tree.
% This is a breadth first search of the tree.
% This corresponds to the top-down pass.
% The bottom-up pass is simply the reverse order.

% Based on code by Erik Sudderth

if nargin < 2, root = 1; end
N = length(adj);
prevNodes = [];
crntNodes = root;
allNextNodes = [];
while (numel(prevNodes) < N)
  allNextNodes = [];
  % add children of all current nodes
  for i = 1:length(crntNodes)
    nextNodes = setdiff(find(adj(crntNodes(i),:)),prevNodes);
    allNextNodes = [allNextNodes, nextNodes];
  end
  % Make list of previously visited nodes
  prevNodes = [prevNodes, crntNodes];
  % Update current frontier
  crntNodes = allNextNodes;
end

end
