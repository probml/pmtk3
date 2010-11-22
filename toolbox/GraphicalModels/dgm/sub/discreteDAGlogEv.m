function L = discreteDAGlogEv(X, G, alpha, ns, prior)
% G is a D*D binary adjacency matrix for a DAG
% X is an N*D matrix where X(i,j) in {1,..,K}
% L = log p(X|G) assuming BDeu(alpha) parameterization

% This file is from pmtk3.googlecode.com


[N,D] = size(X);
L = 0;
if nargin < 3
    alpha = 1; 
end

if nargin < 4
    K = length(unique(X(:)));
    ns  = K*ones(1,D); % we assume all node sizes are the same
end

if nargin < 5, prior= 'BDeu'; end

for i=1:D
   ps = parents(G,i); fam = [ps i];
   ns_fam = ns(fam); ns_ps = ns_fam(1:end-1); ns_self = ns_fam(end);
   psz = prod(ns_ps); % number of parent states
   counts_ijk = computeCounts(X(:,fam), ns_fam);
   counts_ijk = reshape(counts_ijk,  [psz ns_self]);
   switch lower(prior)
     case 'bdeu'
       prior_ijk = (alpha/(psz*ns_self))*onesPMTK(ns_fam);
     case 'unif'
       prior_ijk = (alpha)*onesPMTK(ns_fam);
   end
   prior_ijk = reshape(prior_ijk(:), [psz ns_self]);
   L = L + sum(logbeta(counts_ijk + prior_ijk) - logbeta(prior_ijk));
end
end


function L = logbeta(alpha)
L = sum(gammaln(alpha), 2) - gammaln(sum(alpha, 2));
end


