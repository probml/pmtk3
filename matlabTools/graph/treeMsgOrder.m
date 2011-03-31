
function [msg, prevNodes] = treeMsgOrder(adj, root)
%treeMsgOrder    Find message scheduling for inference on a tree.
%   Determines a sequence of message updates by which BP produces optimal
%   smoothed estimates on a tree-structured undirected graph.
%
%     msg = treeMsgOrder(adj, root)
%
% PARAMETERS:
%   adj = adjacency matrix of tree-structured graph with N nodes
%   root = index of root node used to define scheduling (DEFAULT=1)
% OUTPUTS:
%   msg = 2(N-1)-by-2 matrix such that row i gives the source and 
%         destination nodes for the i^th message passing

% Erik Sudderth
%  May 16, 2003 - Initial version

fprintf('warning: treeMsgOrder goes into infinite loop if tree is not singly connected\n');

  % Check and process input arguments
  if (nargin < 1)
    error('Invalid number of arguments');
  end
  if (nargin < 2)
    root = 1;
  end

  N = length(adj);
  if (root > N | root < 1)
    error('Invalid root node');
  end
  msg = zeros(2*(N-1),2);

  % Recurse from root to define outgoing (scale-recursive) message pass
  msgIndex = N;
  prevNodes = [];
  crntNodes = root;
  while (msgIndex <= 2*(N-1))
    allNextNodes = [];
    for (i = 1:length(crntNodes))
      nextNodes = setdiff(find(adj(crntNodes(i),:)),prevNodes);
      Nnext = length(nextNodes);
      msg(msgIndex:msgIndex+Nnext-1,:) = ...
        [repmat(crntNodes(i),Nnext,1), nextNodes'];
      msgIndex = msgIndex + Nnext;
      allNextNodes = [allNextNodes, nextNodes];
    end
    
    prevNodes = [prevNodes, crntNodes];
    crntNodes = allNextNodes;
  end
  
  % Incoming messages are reverse of outgoing
  msg(1:N-1,:) = fliplr(flipud(msg(N:end,:)));
