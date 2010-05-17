function model = treeFitStruct(X, domain, weights)
% Find MLE undirected tree using Chow-Liu algorithm.
% X(i,j) is value of case i=1:n, node j=1:d
% domain is set of valid values for each variabkle (e.g., [0 1])
% weights is an optional N*1 vector of weights per data case (for EM)
% treeAdjMat is a sparse matrix
%
% O(N d^2) time to compute p(i,j), N=#cases, d=#nodes.
% O(d^2 K^2) tome to compute MI, K=#states
% O(d^2) time to find MWST

if nargin < 2, domain = unique(X(:)); end
N = size(X,1); 
if nargin < 3, weights = ones(1,N); end
 
[mi] = pairwiseMIdiscrete(X, domain, weights);
[treeAdjMat, cost] = minSpanTreePrimSimple(-mi); % find max weight spanning tree
%[treeAdjMat1, cost1] = minSpanTreeKruskal(-wij);
%assert(cost==cost1)
%isequal(treeAdjMat, treeAdjMat1)
%treeAdjMat = setdiag(treeAdjMat, 0);
G = mkRootedTree(treeAdjMat);

model = structure(G, treeAdjMat);

end