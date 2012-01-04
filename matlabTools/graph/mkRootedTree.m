function [T, preorder] = mkRootedTree(adjMat, root)
% Adjmat should be the adjacency matrix of an undirected tree
% All arrows point away from the root (root defaults to 1)
% T is a sparse matrix.
% Also returns nodes in pre-order (parents before children)

% This file is from pmtk3.googlecode.com


%{
Example

     1 
     /  \ 
    2    3
    |
    4

G = zeros(4,4); G(1,[2 3]) = 1; G(2,4) = 1; G = mkSymmetric(G);
If root=1: preorder = [1 2 3 4]

     1 
     /  \
    v    v
    2    3
    |
    v
    4

If root = 4: preorder = [4 2 1 3]

      1
      ^
     /  \
    /    v
    2    3
    ^
    |
    4


%}


if nargin < 2, root = 1; end
Nnodes = size(adjMat,1);
T = sparse(Nnodes, Nnodes); % not the same as T = sparse(n) !

%{
edgeorder = treeMsgOrder(adjMat, root);
Nedges = Nnodes-1;
edges = edgeorder(Nedges+1:end,:);
% edges(e,:)=[s t] ordered from root to leaves
preorder = root;
for e=1:Nedges
  s = edges(e,1);
  t = edges(e,2);
  T(s,t) = 1;
  preorder = [preorder t];
end
%}

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

T = sparse(Nnodes, Nnodes);
for i=1:length(pred)
   if pred(i)>0
      T(pred(i),i)=1; %#ok
   end
end


end
