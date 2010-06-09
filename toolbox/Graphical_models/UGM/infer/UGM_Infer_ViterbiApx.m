function [nodeBel, edgeBel, logZ] = UGM_Infer_ViterbiApx(nodePot,edgePot,edgeStruct,decodeFunc)

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;

y = decodeFunc(nodePot,edgePot,edgeStruct);

nodeBel = zeros(nNodes,maxState);
for n = 1:nNodes
    nodeBel(n,y(n)) = 1;
end

for e = 1:nEdges
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);
    edgeBel(y(n1),y(n2),e) = 1;
end

logZ = UGM_LogConfigurationPotential(y,nodePot,edgePot,edgeEnds);