function model = treeFit(X, domain, weights)
% Fit tree-strucutred GM  using Chow-Liu algorithm.
% Input:
% X(i,j) is value of case i=1:n, node j=1:d
% domain is set of valid values for each variable (e.g., [0 1])
% weights is an optional N*1 vector of weights per data case (needed for EM)
%
% Output: model is a struct with these fields
%
% adjmat is a sparse symmetric matrix (undirected graph)
% pa(n) = parent of node n, or 0 if n is the root
% msgorder(m, :) = [src destn] for m'th message 
% nodeorder(i) = i'th node in order descending from root to leaves
% model.CPDs{i} = [K * K] matrix, where

[Ncases Nnodes] = size(X);
if nargin < 2, domain = unique(X(:)); end
if nargin < 3, weights = ones(1,Ncases); end
model.adjmat = treeFitStruct(X, domain, weights);
model.root = 1;
[model.msgorder, model.nodeorder] = treeMsgOrder(model.adjmat, model.root);
for n=1:Nnodes
  if n==model.root
    model.pa(n) = 0;
  else
    model.pa(n) = parents(model.adjmat, n);
  end
end
dirichlet = 0; % smoothing param
model.CPDs = treeFitParams(G,  X, dirichlet);
end


function treeAdjMat = treeFitStruct(X, domain, weights)
% 
%
% O(N d^2) time to compute p(i,j), N=#cases, d=#nodes.
% O(d^2 K^2) tome to compute MI, K=#states
% O(d^2) time to find MWST

[mi] = mutualInfoAllPairsDiscrete(X, domain, weights);
[treeAdjMat, cost] = minSpanTreePrim(-mi); % find max weight spanning tree
%[treeAdjMat1, cost1] = minSpanTreeKruskal(-wij);
%assert(cost==cost1)
%isequal(treeAdjMat, treeAdjMat1)
%treeAdjMat = setdiag(treeAdjMat, 0);
%G = mkRootedTree(treeAdjMat);
%model = structure(G, treeAdjMat);
end

function CPDs = treeFitParams(par,  X, dirichlet)
% Find the MAP estimate of the parameters of the CPTs.
%  X(i,j) is value of node j in case i, i=1:n, j=1:d
% par(n) = parent of node n, or [] if n is the root

if nargin < 3, dirichlet = 0; end
d = size(X,2);
[X, support] = canonizeLabels(X); % 1...K requried by compute_counts
K = length(support);
sz = K*ones(1,d); % we assume every node has K states
CPDs = cell(1,d);
for i=1:d
   pa = par(i); % parents(G, i);
   if pa==0 % no parent
      cnt = computeCounts(X(:,i), sz(i));
      prior  = (dirichlet/numel(cnt))*onesPMTK(size(cnt)); %BDeu
      CPDs{i} = normalize(cnt+prior);
   else
      j = pa;
      cnt = computeCounts(X(:,[j i]), sz([j i])); % parent then child
      prior  = (dirichlet/numel(cnt))*onesPMTK(size(cnt)); %BDeu
      CPDs{i} = mkStochastic(cnt+prior);
   end  
end

end


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
%   prevNodes = list of nodes in order from root to leaves

% Erik Sudderth
%  May 16, 2003 - Initial version

N = length(adj);
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

end