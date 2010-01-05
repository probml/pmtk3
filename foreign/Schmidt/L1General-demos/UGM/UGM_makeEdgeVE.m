function [V,E] = UGM_makeEdgeVE(edgeEnds,nNodes)

nEdges = size(edgeEnds,1);

nNei = zeros(nNodes,1);
nei = zeros(nNodes,0);
for e = 1:nEdges
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);
    nNei(n1) = nNei(n1)+1;
    nNei(n2) = nNei(n2)+1;
    nei(n1,nNei(n1)) = e;
    nei(n2,nNei(n2)) = e;
end

edge = 1;
for n = 1:nNodes
    V(n) = edge;
    nodeEdges = sort(nei(n,1:nNei(n)));
    E(edge:edge+length(nodeEdges)-1,1) = nodeEdges;
    edge = edge+length(nodeEdges);
end
V(nNodes+1) = edge;