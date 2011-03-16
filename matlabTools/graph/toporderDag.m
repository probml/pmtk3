function [G, toporder, invtoporder] = toporderDag(G)
% Re-arrange DAG so nodes are topologically ordered
% toporder(i) maps from user to internal numbering
% invtoporder(j) maps from itnernal to user numbers
%
% Example:
%  2  3 
%   \ /
%    v
%    1
%
% toporder = [ 2 3 1], invtoporder = [3 1 2], names = '2', '3', '1'
% ew G
%
%    1  2
%     \ /
%      v
%      3

if nargin == 0
  G = zeros(3,3);
  G([2 3], 1) = 1;
end

Nnodes = size(G,1);
%graphviz(adj, 'labels', nodeNames, 'directed', 1, 'filename', 'tmp');

[toporder] = toposort(G);
for j=1:Nnodes
  invtoporder(j) = find(toporder==j);
end

G = G(toporder, toporder);

%{
GorigOrder = G;
G = zeros(Nnodes, Nnodes);
for j=1:Nnodes
  pa = parents(GorigOrder, j);
  G(invtoporder(pa), invtoporder(j))  = 1;
end
G2 = GorigOrder(toporder, toporder);
isequal(G, G2)
%}

end
