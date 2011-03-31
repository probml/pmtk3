function model = treegmFit(X,  obs, obsType, weights)
% Fit tree-structured GM  using Chow-Liu algorithm.
% INPUT
% X(i,j) is value of case i=1:n, node j=1:d
%  X(i,j) should be discrete values, eg {0,1} or {1,2,3}
%  The current implementation assumes each node has the same set of values
% 
% Optionally we can have observed local evidence for each node:
% obs(i,j,:) are the observations for node j in case i
% So obs is Ncases * Nnodes * Ndims
% obsType is {'gauss', 'local', 'discrete'}
% If 'localev', we assume obs(i,j,:) = p(yj=:) in case i is local evidence
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
if nargin < 3, obsType = 'none'; end
if nargin < 4, weights = ones(1,Ncases); end



% Chow-Liu
% O(N d^2) time to compute p(i,j,vi,vj), N=#cases, d=#nodes.
% O(d^2 K^2) tome to compute MI, K=#states
% O(d^2) time to find MWST
[mi, nmi, pij, pi] = mutualInfoAllPairsDiscrete(X, unique(X(:)), weights); %#ok
%[mi] = mutualInfoAllPairsDiscrete(X, domain, weights);
[adjmat, cost] = minSpanTreePrim(-mi); % find max weight spanning tree

%disp('treegmFit: setting to empty graph')
%adjmat = zeros(Nnodes, Nnodes); % sanity check

root = 1;
Nstates = size(pi,2);
model.Nstates = Nstates;
model.Nnodes = Nnodes;




%  Make a directed version of the tree
% so we can compute logprob
dirTree = mkRootedTree(adjmat, root);
pa = zeros(1, Nnodes);
CPDs = cell(1, Nnodes);
roots = [];
for n=1:Nnodes
  rents = parents(dirTree, n);
  if isempty(rents)
    pa(n) = 0;
    CPDs{n} = pi(n,:)';
    roots = [roots n];
  else
    p = rents;
    pa(n) = p;
    % can have at most one parent in a rooted tree
    CPDs{n} = squeeze(pij(p,n,:,:)) ./ repmat(pi(p,:)', 1, Nstates);
  end
end


% Make an undirected model
[~, edges] = treeMsgOrderPmtk(adjmat, root);
Nedges  = size(edges,1);
%[edgeorder] = treeMsgOrder(adjmat, root);
%Nedges = Nnodes-1;
%edges = edgeorder(Nedges+1:end,:);
% edges(e,:)=[p c] ordered from root to leaves

%nodePots = [CPDs{root} ones(Nstates,1)];
%nodePotNdx = [1 2*ones(1,Nnodes-1)];

nodePots = [ones(Nstates,1) CPDs{roots}];
nodePotNdx = ones(1, Nnodes);
nodePotNdx(roots) = (1:numel(roots))+1;
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

% It is useful to visualize
% the strenght of each edge in terms of normalized MI
model.edge_weights = model.adjmat  .* mi/max(mi(:));
% For binary nodes, we make the edge -ve if p(bi=1,bj=1) < p(bi=1)*p(bj=1)
% This trick is due to Myung Jin Choi
if Nstates==2
  for i=1:Nnodes
    for j=i+1:Nnodes
      prob = squeeze(pij(i,j,:,:));
      p01 = prob(1, 2);
      p10 = prob(2, 1);
      p11 = prob(2, 2);
      if(p11 < (p01+p11)*(p10+p11))
        model.edge_weights(i,j) = -model.edge_weights(i,j);
        model.edge_weights(j,i) = -model.edge_weights(j,i);
      end
    end
  end
end

% Fit observation model if desired
model.obsmodel.obsType = obsType;
model.obsmodel.Nstates = Nstates;
if isempty(obs), return; end
switch obsType
  case 'discrete'
    error('not yet implemented')
  case 'localev'
    % no need to fit anything
  case 'gauss'
   [model.obsmodel.localCPDs, model.obsmodel.localCPDpointers, ...
     model.obsmodel.localMu, model.obsmodel.localSigma] = ...
     condGaussCpdMultiFit(X, obs, Nstates);
end

end


%{
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
%}



