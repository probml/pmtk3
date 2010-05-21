%% Make noisy X
getNoisyX

%% Make Blocks

nodeNums = reshape(1:nNodes,nRows,nCols);
blocks1 = zeros(nNodes/2,1);
blocks2 = zeros(nNodes/2,1);
b1Ind = 0;
b2Ind = 0;
for j = 1:nCols
    if mod(j,2) == 1
        blocks1(b1Ind+1:b1Ind+nCols-1) = nodeNums(1:nCols-1,j);
        b1Ind = b1Ind+nCols-1;
        
        blocks2(b2Ind+1) = nodeNums(nRows,j);
        b2Ind = b2Ind+1;
    else
        blocks1(b1Ind+1) = nodeNums(1,j);
        b1Ind = b1Ind+1;
        
        blocks2(b2Ind+1:b2Ind+nCols-1) = nodeNums(2:nCols,j);
        b2Ind = b2Ind+nCols-1;
    end
end
blocks = {blocks1;blocks2};

%% Block ICM

% Regular ICM
fprintf('Decoding with ICM...\n');
ICMDecoding = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);

figure(3);
imagesc(reshape(ICMDecoding,nRows,nCols));
colormap gray
title('ICM Decoding of Noisy X');
fprintf('(paused)\n');
pause

% Block ICM
fprintf('Decoding with Block ICM...\n');
BlockICMDecoding = UGM_Decode_Block_ICM(nodePot,edgePot,edgeStruct,blocks,@UGM_Decode_Tree);

figure(4);
imagesc(reshape(BlockICMDecoding,nRows,nCols));
colormap gray
title('Block ICM Decoding of Noisy X');
fprintf('(paused)\n');
pause

%% Block Mean Field

% Regular Mean Field
fprintf('Running Mean Field Inference...\n');
[nodeBelMF,edgeBelMF,logZMF] = UGM_Infer_MeanField(nodePot,edgePot,edgeStruct);

figure(5);
imagesc(reshape(nodeBelMF(:,2),nRows,nCols));
colormap gray
title('Mean Field Estimates of Marginals');
fprintf('(paused)\n');
pause

% Block Mean Field
fprintf('Running Block Mean Field Inference...\n');
[nodeBelBMF,edgeBelBMF,logZBMF] = UGM_Infer_Block_MF(nodePot,edgePot,edgeStruct,blocks,@UGM_Infer_Tree);

figure(6);
imagesc(reshape(nodeBelBMF(:,2),nRows,nCols));
colormap gray
title('Block Mean Field Estimates of Marginals');
fprintf('(paused)\n');
pause

%% Block Gibbs Sampling

% Regular Gibbs Sampling
fprintf('Running Gibbs Sampler...\n');
burnIn = 10;
edgeStruct.maxIter = 20;
samplesGibbs = UGM_Sample_Gibbs(nodePot,edgePot,edgeStruct,burnIn);

figure(7);
for i = 1:10
    subplot(2,5,i);
    imagesc(reshape(samplesGibbs(:,i*edgeStruct.maxIter/10),nRows,nCols));
    colormap gray
end
suptitle('Samples from Gibbs sampler');

figure(8);
imagesc(reshape(mean(samplesGibbs,2),nRows,nCols));
colormap gray
title('Gibbs Estimates of Marginals');
fprintf('(paused)\n');
pause

% Block Gibbs Sampling
fprintf('Running Block Gibbs Sampler...\n');
samplesBlockGibbs = UGM_Sample_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,@UGM_Sample_Tree);

figure(9);
for i = 1:10
    subplot(2,5,i);
    imagesc(reshape(samplesBlockGibbs(:,i*edgeStruct.maxIter/10),nRows,nCols));
    colormap gray
end
suptitle('Samples from Block Gibbs sampler');

figure(10);
imagesc(reshape(mean(samplesBlockGibbs,2),nRows,nCols));
colormap gray
title('Gibbs Estimates of Marginals');
fprintf('(paused)\n');
pause