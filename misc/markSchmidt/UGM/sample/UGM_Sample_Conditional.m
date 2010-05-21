function [samples] = UGM_Sample_Conditional(nodePot,edgePot,edgeStruct,clamped,sampleFunc)
% Do sampling with observed values

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
maxIter = edgeStruct.maxIter;

[clampedNP,clampedEP,clampedES,edgeMap] = UGM_makeClampedPotentials(nodePot,edgePot,edgeStruct,clamped);

clampedSamples = sampleFunc(clampedNP,clampedEP,clampedES);

% Construct node beliefs
samples = repmat(clamped,[1 maxIter]);
samples(samples==0) = clampedSamples;