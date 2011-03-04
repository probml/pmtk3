function B = betheFreeEnergy(G, nodePots, edgePots, nodeBel, edgeBel)
% Approximate the log likelihood for a pairwise MRF
% If the model is a tree, this is exact
% F = -theta^T tau - sum_{st} H(s,t) + sum_s (d(s)-1) H(s)
% where exp(-theta)=[nodePot edgePot]
% tau = [nodeBel edgeBel]
% H(s,t) = entropy edgeBel(:,:,e)
% H(s) = entropy nodeBel(:,s)
% d(s) = degree of node s = num neighbors
%
% So F=NLL = expected energy - entropy
% where energy = log prob

fprintf('warning: betheFreeEnergy may be buggy\n');

%Nnodes = model.Nnodes;
%Nedges = model.Nedges;
%G = model.adjmat;
Nnodes = size(nodePots,2);
Nedges = size(edgePots,3);

entropyNodes = zeros(1, Nnodes);
energyNodes = zeros(1, Nnodes);
degreeNodes = zeros(1, Nnodes);
weightedEntropyNodes = zeros(1, Nnodes);
for n=1:Nnodes
  nodePot = nodePots(:,n);
  energyNodes(n) = sum(nodeBel(:,n) .*  log(nodePot + eps));
  entropyNodes(n) =  entropyPmtk(nodeBel(:,n));
  degreeNodes(n) = numel(neighbors(G, n));
  weightedEntropyNodes(n)  = (degreeNodes(n)-1)*entropyNodes(n);
end

entropyEdges = zeros(1, Nedges);
energyEdges = zeros(1, Nedges);
for e=1:Nedges
  edgePot = edgePots(:,:,e);
  energyEdges(e) =  sum(sum(edgeBel(:,:,e) .* log(edgePot + eps)));
  entropyEdges(e) = entropyPmtk(edgeBel(:,:,e));
end

energy =  sum(energyNodes) + sum(energyEdges);
B = energy - sum(entropyEdges) + sum(weightedEntropyNodes);

end