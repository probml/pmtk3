
function [edgesUp, edgesDown] = treeMsgOrderPmtk(adj, root)
%treeMsgOrder    Find message scheduling for inference on a tree.
%
% edgesUp(e,:) = [c p] where edge is oriented p->c en route to root
% edgesDown(e,:) = [p c]
%
% This is similar to treeMsgOrder by Erik Sudderth,
% except it works on disconnected  trees (forests).
% We go from leaves to root and back.
%
%Example
%
%      1                
%   e3/  \e1   
%    2    3
% e2 |
%    4
%
%
%G = zeros(4,4); G(1,[2 3]) = 1; G(2,4) = 1;  G = mkSymmetric(G);
%[edgesUp, edgesDown] = treeMsgOrderPmtk(G, 1);
% edgesUp
%     3     1
%     4     2
%     2     1
%
% edgesDown
%     1     2
%     2     4
%     1     3
%     
%
% Now try adding disconnected 5->6 edge
%
%G = zeros(6,6); G(1,[2 3]) = 1; G(2,4) = 1;  G(5,6)=1;
%G = mkSymmetric(G);
%[edgesUp, edgesDown] = treeMsgOrderPmtk(G, 1);
% Same except edgesUp begins with [6 5]
% and edgesDown ends with [5 6]


N = length(adj);
[T, preorder] = mkRootedTree(adj, root);
postorder = preorder(end:-1:1);

% Recurse from root to define outgoing (scale-recursive) message pass
edges = [];
for i=1:(numel(postorder)-1)
  c = postorder(i);
  p = parents(T, c);
  if ~isempty(p)
    edges = [edges; [c p]];
  end
end

% Incoming messages are reverse of outgoing
%msg = [edges; fliplr(flipud(edges))];
edgesUp = edges;
edgesDown = fliplr(flipud(edgesUp));

end