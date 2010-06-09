%% Make noisy X
getNoisyX

%% Mean field inference

fprintf('Running Mean Field Inference...\n');
[nodeBelMF,edgeBelMF,logZMF] = UGM_Infer_MeanField(nodePot,edgePot,edgeStruct);

figure(3);
imagesc(reshape(nodeBelMF(:,2),nRows,nCols));
colormap gray
title('Mean Field Estimates of Marginals');
fprintf('(paused)\n');
pause

fprintf('Running mean field inference and computing max of marginals\n');
maxOfMarginalsMFdecode = UGM_Decode_MaxOfMarginals(nodePot,edgePot,edgeStruct,@UGM_Infer_MeanField);

figure(4);
imagesc(reshape(maxOfMarginalsMFdecode,nRows,nCols));
colormap gray
title('Max of mean field marginals');
fprintf('(paused)\n');
pause

%% Loopy Belief Propagation

fprintf('Running loopy belief propagation for inference...\n');
[nodeBelLBP,edgeBelLBP,logZLBP] = UGM_Infer_LBP(nodePot,edgePot,edgeStruct);

figure(5);
imagesc(reshape(nodeBelLBP(:,2),nRows,nCols));
colormap gray
title('Loopy Belief Propagation Estimates of Marginals');
fprintf('(paused)\n');
pause

fprintf('Running loopy belief propagation and computing max of marginals\n');
maxOfMarginalsLBPdecode = UGM_Decode_MaxOfMarginals(nodePot,edgePot,edgeStruct,@UGM_Infer_LBP);

figure(6);
imagesc(reshape(maxOfMarginalsLBPdecode,nRows,nCols));
colormap gray
title('Max of Loopy Belief Propagation Marginals');
fprintf('(paused)\n');
pause

fprintf('Running loopy belief propagation for decoding...\n');
decodeLBP = UGM_Decode_LBP(nodePot,edgePot,edgeStruct);

figure(7);
imagesc(reshape(decodeLBP,nRows,nCols));
colormap gray
title('Loopy Belief Propagation Decoding');
fprintf('(paused)\n');
pause

%% Tree-Reweighted Belief Propagation

fprintf('Running tree-reweighted belief propagation for inference...\n');
[nodeBelTRBP,edgeBelTRBP,logZTRBP] = UGM_Infer_TRBP(nodePot,edgePot,edgeStruct);

figure(8);
imagesc(reshape(nodeBelTRBP(:,2),nRows,nCols));
colormap gray
title('Tree-Reweighted Belief Propagation Estimates of Marginals');
fprintf('(paused)\n');
pause

fprintf('Running tree-reweighted belief propagation and computing max of marginals\n');
maxOfMarginalsTRBPdecode = UGM_Decode_MaxOfMarginals(nodePot,edgePot,edgeStruct,@UGM_Infer_TRBP);

figure(9);
imagesc(reshape(maxOfMarginalsTRBPdecode,nRows,nCols));
colormap gray
title('Max of Tree-Reweighted Belief Propagation Marginals');
fprintf('(paused)\n');
pause

fprintf('Running tree-reweighted belief propagation for decoding...\n');
decodeTRBP = UGM_Decode_TRBP(nodePot,edgePot,edgeStruct);

figure(10);
imagesc(reshape(decodeTRBP,nRows,nCols));
colormap gray
title('Tree-Reweighted Belief Propagation Decoding');
fprintf('(paused)\n');
pause

%% Variational MCMC

burnIn = 100;
edgeStruct.maxIter = 100;
variationalProportion = .25;
samplesVarMCMC = UGM_Sample_VarMCMC(nodePot,edgePot,edgeStruct,burnIn,variationalProportion);
