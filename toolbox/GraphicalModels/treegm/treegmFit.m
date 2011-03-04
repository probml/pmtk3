function model = treegmFit(X,  obs, obsType, weights)
% Fit tree-structured GM  using Chow-Liu algorithm.
% INPUT
% X(i,j) is value of case i=1:n, node j=1:d
%  X(i,j) should be discrete values, eg {0,1} or {1,2,3}
%  The current implementation assumes each node has the same set of values
% 
% Optionally we can have observed local evidence for each node:
% obs(i,j,:) are the observations for node j in case i
% obsType is {'gauss', 'discrete'}
%
% weights is an optional N*1 vector of weights per data case
% (needed for fitting mixtures of trees with EM)
%
% OUTPUT:
% model is a struct with these fields:
%
% adjmat is a sparse symmetric matrix (undirected graph)
% pa(n) = parent of node n, or 0 if n is the root
% msgorder(m, :) = [src destn] for m'th message 
% nodeorder(i) = i'th node in order descending from root to leaves
% model.CPDs{i} = [K * K] matrix, where

[Ncases Nnodes] = size(X);
if nargin < 2, obs = []; end
if nargin < 3, obsType = []; end
if nargin < 4, weights = ones(1,Ncases); end



% Chow-Liu
% O(N d^2) time to compute p(i,j), N=#cases, d=#nodes.
% O(d^2 K^2) tome to compute MI, K=#states
% O(d^2) time to find MWST
[mi, nmi, pij, pi] = mutualInfoAllPairsDiscrete(X, unique(X(:)), weights); %#ok
%[mi] = mutualInfoAllPairsDiscrete(X, domain, weights);
[adjmat, cost] = minSpanTreePrim(-mi); % find max weight spanning tree
root = 1;
Nstates = size(pi,2);


%  Make a directed version of the tree
% so we can compute logprob
dirTree = mkRootedTree(adjmat, root);
pa = zeros(1, Nnodes);
CPDs = cell(1, Nnodes);
for n=1:Nnodes
  if n==root
    pa(n) = 0;
    CPDs{n} = pi(n,:)';
  else
    pa(n) = parents(dirTree, n);
    p = pa(n);
    CPDs{n} = squeeze(pij(p,n,:,:)) ./ repmat(pi(p,:)', 1, Nstates);
  end
end


% Make an undirected model
edgeorder = treeMsgOrder(adjmat, root);
Nedges = Nnodes-1;
edges = edgeorder(Nedges+1:end,:);
% edges(e,:)=[s t] ordered from root to leaves

nodePots = [CPDs{root} ones(Nstates,1)];
nodePotNdx = [1 2*ones(1,Nnodes-1)];
edgePots = zeros(Nstates, Nstates, Nedges);
edgePotNdx = zeros(Nnodes, Nnodes);
for e=1:Nedges
  s = edges(e, 1); t = edges(e, 2); %s -> t
  edgePotNdx(s,t) = e;
  edgePots(:,:,e) = CPDs{t}; % row = s, col = t
end

model = treegmCreate(adjmat, nodePots, edgePots, nodePotNdx, edgePotNdx);

% We store these directed quantities used by treegmLogprob
model.CPDs = CPDs;
model.pa = pa;
model.dirTree = dirTree;

% Fit observation model
if isempty(obs), return; end
switch obsType
  case 'discrete'
    error('not yet implemented')
  case 'gauss'
    Ndims = size(obs,3); %#ok
    localCPDs = cell(1, Nnodes);
    localCPDpointers = 1:Nnodes; % each node has its own CPD
    for n=1:Nnodes
      Y = squeeze(obs(:,n,:)); % Y(case,dim)
      Z = X(:,n); % 
      mu    = partitionedMean(Y, Z, Nstates)';
      Sigma = partitionedCov(Y, Z,  Nstates);
      % should regularize Sigma if Ndim >> 1 
      localCPDs{n} = condGaussCpdCreate(mu,  Sigma);
    end
end
model.localCPDs = localCPDs;
model.localCPDpointers = localCPDpointers;

end



function [CPDs, support] = treeFitParams(par,  X, dirichlet)
% Find the MAP estimate of the parameters of the CPTs.
%  X(i,j) is value of node j in case i, i=1:n, j=1:d
% par(n) = parent of node n, or [] if n is the root

error('deprecated')
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

