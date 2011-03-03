function model = treegmFit(X, domain, weights)
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
[model.undirTree, model.dirTree] = treeFitStruct(X, domain, weights);
model.root = 1;
[model.edgeorder] = treeMsgOrder(model.undirTree, model.root);
for n=1:Nnodes
  if n==model.root
    model.pa(n) = 0;
  else
    model.pa(n) = parents(model.dirTree, n);
  end
end
dirichlet = 0; % smoothing param
[model.CPDs, model.support] = treeFitParams(model.pa,  X, dirichlet);
model.Nstates = numel(model.support);

end


function [treeAdjMat, dirTree] = treeFitStruct(X, domain, weights)
% 
%
% O(N d^2) time to compute p(i,j), N=#cases, d=#nodes.
% O(d^2 K^2) tome to compute MI, K=#states
% O(d^2) time to find MWST

%[mi, nmi, pij, pi] = mutualInfoAllPairsDiscrete(X, domain, weights);
[mi] = mutualInfoAllPairsDiscrete(X, domain, weights);
[treeAdjMat, cost] = minSpanTreePrim(-mi); % find max weight spanning tree
dirTree = mkRootedTree(treeAdjMat);
end

function [CPDs, support] = treeFitParams(par,  X, dirichlet)
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

