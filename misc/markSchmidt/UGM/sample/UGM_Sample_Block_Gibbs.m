function [samples] = UGM_Sample_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,sampleFunc)
% Block Gibbs Sampling

[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;
maxIter = edgeStruct.maxIter;

% Initialize
nBlocks = length(blocks);
[junk y] = max(nodePot,[],2);

samples = zeros(nNodes,0);

for i = 1:burnIn+maxIter
    
    if i <= burnIn
        fprintf('Generating burnIn sample %d of %d\n',i,burnIn);
    else
        fprintf('Generating sample %d of %d\n',i-burnIn,maxIter);
    end

    for b = 1:nBlocks
        clamped = y;
        clamped(blocks{b}) = 0;

        [clampedNP,clampedEP,clampedES] = UGM_makeClampedPotentials(nodePot, edgePot, edgeStruct, clamped);

        clampedES.maxIter = 1;
        y(blocks{b}) = sampleFunc(clampedNP,clampedEP,clampedES);
    end

    if i > burnIn
        samples(:,i-burnIn) = y;
    end
end