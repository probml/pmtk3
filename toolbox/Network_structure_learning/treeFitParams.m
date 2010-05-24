function model = treeFitParams(model,  X, dirichlet)
% Find the MAP estimate of the parameters of the CPTs.
%  X(i,j) is value of node j in case i, i=1:n, j=1:d

if nargin < 3, dirichlet = 0; end
G = model.G;
d = size(X,2);
[X, support] = canonizeLabels(X); % 1...K requried by compute_counts
K = length(support);
sz = K*ones(1,d); % we assume every node has K states
CPDs = cell(1,d);
for i=1:d
   pa = parents(G, i);
   if isempty(pa) % no parent
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
model.CPDs = CPDs;

end