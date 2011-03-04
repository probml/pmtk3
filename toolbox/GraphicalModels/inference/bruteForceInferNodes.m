function [logZ, nodeBel, edgeBel] = bruteForceInferNodes(factors, edges)
% Compute all node marginals given a set of factors using enuemration
% We assume all nodes are discrete and have the same num states
% factors{f} is a tabular factor
%
% logZ is log normalization constant
% nodeBel(:,t)
% 
% Optional: if you pass in edges matrix size E*2, we also compute
% edgeBel(:,:,e) where edges(e,:)=[s t]



nodeSizes = [];
for f=1:numel(factors)
  nodeSizes(factors{f}.domain) = factors{f}.sizes;
end
if ~all(nodeSizes==nodeSizes(1))
  error('all node sizes must be the same')
end
if prod(nodeSizes) > 1024
  fprintf('warning: you are about to create a joint table with %d entries', prod(nodeSizes));
end
Nnodes = numel(nodeSizes);
Nstates = nodeSizes(1);

% Compute marginla prob of each node
queries = num2cell(1:Nnodes);
[logZ, bels] = bruteForceInferQuery(factors, queries);
% Convert the tabular factors to standard matrix
nodeBel = zeros(Nstates, Nnodes);
for i=1:Nnodes
  nodeBel(:,i) = bels{i}.T(:);
end

if nargin < 2, return; end
% Computed joint prob of each edge
Nedges = size(edges, 1);
edgeBel = ones(Nstates, Nstates, Nedges);
queries = num2cell(edges, 2);
[logZ2, bels2] = bruteForceInferQuery(factors, queries); %#ok
if Nedges == 1, bels2 = {bels2}; end
for e=1:Nedges
  edgeBel(:,:,e) = bels2{e}.T;
end
assert(approxeq(logZ, logZ2))

end