%% Make noisy X
getNoisyX

%% Gibbs Sampling

fprintf('Running Gibbs Sampler...\n');
burnIn = 1000;
edgeStruct.maxIter = 1000;
samplesGibbs = UGM_Sample_Gibbs(nodePot,edgePot,edgeStruct,burnIn);

figure(3);
for i = 1:10
    subplot(2,5,i);
    imagesc(reshape(samplesGibbs(:,i*edgeStruct.maxIter/10),nRows,nCols));
    colormap gray
end
suptitle('Samples from Gibbs sampler');
fprintf('(paused)\n');
pause

%% Approximate Decoding with Sampling

fprintf('Running Gibbs sampler for decoding\n');
gibbsDecoding = UGM_Decode_Sample(nodePot, edgePot, edgeStruct,@UGM_Sample_Gibbs,burnIn);

figure(4);
imagesc(reshape(gibbsDecoding,nRows,nCols));
colormap gray
title('Gibbs Decoding of Noisy X');
fprintf('(paused)\n');
pause

%% Approximate Inference with Sampling

fprintf('Running Gibbs sampler for inference\n');
[gibbsNodeBel,gibbsEdgeBel,gibbsLogZ] = UGM_Infer_Sample(nodePot, edgePot, edgeStruct,@UGM_Sample_Gibbs,burnIn);

figure(5);
imagesc(reshape(gibbsNodeBel(:,2),nRows,nCols));
colormap gray
title('Gibbs Estimates of Marginals of Noisy X');
fprintf('(paused)\n');
pause

figure(6);
imagesc(reshape(gibbsNodeBel(:,2)>.5,nRows,nCols));
colormap gray
title('Thresholded Gibbs Estimats of Marginals of Noisy X');
fprintf('(paused)\n');
pause

fprintf('Running Gibbs sampler for decoding with max of marginals\n');
maxOfMarginalsGibbsDecode = UGM_Decode_MaxOfMarginals(nodePot,edgePot,edgeStruct,@UGM_Infer_Sample,@UGM_Sample_Gibbs,burnIn);
