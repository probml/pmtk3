function L = discreteDAGlogEv(X, G, alpha)
% G is a D*D binary adjacency matrix for a DAG
% X is an N*D matrix where X(i,j) in {1,..,K}
% L = log p(X|G) assuming BDeu(alpha) parameterization

if nargin < 3, alpha = 1; end
[N,D] = size(X);
K = length(unique(X(:)));
L = 0;
ns  = K*ones(1,D); % we assume all node sizes are the same
for i=1:D
   ps = parents(G,i); fam = [ps i];
   ns_fam = ns(fam); ns_ps = ns_fam(1:end-1); ns_self = ns_fam(end);
   psz = prod(ns_ps); % number of parent states
   counts_ijk = computeCounts(X(:,fam), ns_fam);
   counts_ijk = reshape(counts_ijk,  [psz ns_self]);
   prior_ijk = (alpha/(psz*ns_self))*myones(ns_fam);% BDeu prior
   prior_ijk = reshape(prior_ijk(:), [psz ns_self]);
   L = L + sum(logbeta(counts_ijk + prior_ijk) - logbeta(prior_ijk));
end
end


function L = logbeta(alpha)
L = sum(gammaln(alpha)) - gammaln(sum(alpha));
end


