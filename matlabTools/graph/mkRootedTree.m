function [T, preorder] = mkRootedTree(adjMat, root)
% Adjmat should be the adjacency matrix of an undirected tree
% All arrows point away from the root (root defaults to 1)
% T is a sparse matrix.
% Also returns nodes in pre-order

% This file is from matlabtools.googlecode.com

if nargin < 2, root = 1; end
n = length(adjMat);
T = sparse(n,n); % not the same as T = sparse(n) !

%{
directed = 0;
verbose = true;
[d, preorder, postorder, hascycle, f, pred] = dfsPMTK(adjMat, root, directed);
if hascycle
   warning('not a tree!')
end
%}

[d dt ft pred] = dfs(adjMat,root,1); %#ok (gaimc package)
% dt is discovery time, pred is predecessor in search
dt(root) = 0;
[junk, preorder]= sort(dt);
preorder = rowvec(preorder);

for i=1:length(pred)
   if pred(i)>0
      T(pred(i),i)=1; %#ok
   end
end

end
