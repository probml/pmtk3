function [tree, cpts, ll, G, wij, probi, probij] = chowliu(data, sz, dirichlet)
% Make a chow-liu tree
% data(j,n) is variable  j in case n; values are assumed to be 1,2,...K (no zeros!)
% sz(j) is the number of states for variable j (optional)
% dirichlet is the optional strenght of uniform dirichlet prior
%
% tree(j) is the parent of j, or 0 if j is a root
% cpts{j}  is the conditional probability table for node j
% ll(n) is log likelihood of case n (optional)
% G(i,j) is the adjacency matrix

[d N] = size(data);

if nargin < 2
  for i=1:d
    u = unique(data(i,:));
    sz(i) = length(u);
    if ismember(0,u)
      error('cannot have 0s')
    end
  end
end
if nargin < 3, dirichlet = 0; end % use MLE by default

probi = cell(1,d);
hi = zeros(1,d);
for i=1:d
  cnt = compute_counts(data(i,:), sz(i));
  pi = cnt/N;
  hi(i) = -sum(pi  .* log(pi + eps));
  probi{i} = (cnt+dirichlet)/(N+sz(i)*dirichlet);
  % posterior mean = (N(k)+prior(k))/(sum_k' N(k')+prior(k'))
end

probij = cell(d,d);
hij = zeros(d,d);
wij = zeros(d,d);
for i=1:d
  wij(i,i) = hi(i);
  for j=i+1:d
    cnt = compute_counts(data([i j],:), sz([i j]));
    pij = cnt(:)/N;
    hij(i,j) = -sum(pij .* log(pij + eps));
    wij(i,j) = hi(i) + hi(j) -hij(i,j); % mutual information
    wij(j,i) = wij(i,j);
    probij{i,j} = (cnt+dirichlet)/(N+sz(i)*sz(j)*dirichlet);
    probij{j,i} = probij{i,j}';

  end
end

root = 1;
tree = mwst(-wij,root); % maximum weight spanning tree

G = zeros(d,d);
cpts=cell(d,1);
for i=1:d
  if (tree(i)==0) % no parent
    cpts{i} = probi{i};
  else
    j = tree(i); % j is i's parent
    G(j,i) = 1;
    cpts{i} = probij{i,j}' ./ repmat(probi{j}(:), 1, sz(i)); % cpts{i}(j,i) = p(i|j)=p(i,j)/p(j)
  end
end

if nargout >= 3
  ll = treeloglik(tree, cpts, data);
end
