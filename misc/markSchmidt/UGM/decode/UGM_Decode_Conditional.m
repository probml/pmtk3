function [nodeLabels] = UGM_Decode_Conditional(nodePot,edgePot,edgeStruct,clamped,decodeFunc)
% Do decoding with observed values

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;

[clampedNP,clampedEP,clampedES,edgeMap] = UGM_makeClampedPotentials(nodePot,edgePot,edgeStruct,clamped);

clampedNodeLabels = decodeFunc(clampedNP,clampedEP,clampedES);

% Construct node beliefs
nodeLabels = clamped;
nodeLabels(nodeLabels==0) = clampedNodeLabels;