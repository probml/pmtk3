function T = mkRootedTree(adjMat, root)
% Adjmat should be the adjmat of an undirected tree
% All arrows point away from the root (root defaults to 1)
if nargin < 2, root = 1; end
n = length(adjMat);
T = sparse(n,n); % not the same as T = sparse(n) !
directed = 0;
verbose = true;
[d, preorder, postorder, hascycle, f, parent] = dfs(adjMat, root, directed); %#ok
if hascycle
   warning('not a tree!')
end
pred = parent;
for i=1:length(pred)
   if pred(i)>0
      T(pred(i),i)=1;
   end
end

end