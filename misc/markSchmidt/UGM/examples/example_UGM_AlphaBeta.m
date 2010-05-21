%% Make noisy X
getNoisyX2

% imagesc(reshape(nodePot(:,1),nRows,nCols))
% X = reshape(X,32,32,4);
% imagesc(reshape(Xrgb(:,:,1),nRows,nCols))
% return


%% ICM

ICMDecoding = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);

figure(3);
imagesc(reshape(ICMDecoding,nRows,nCols));
colormap([1 1 1;1 0 0;0 1 0;0 0 1]);
title('ICM Decoding of Noisy X');
fprintf('(paused)\n');
pause


%% Block ICM

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

blockICMDecoding = UGM_Decode_Block_ICM(nodePot,edgePot,edgeStruct,blocks,@UGM_Decode_ICM,ICMDecoding);

figure(4);
imagesc(reshape(blockICMDecoding,nRows,nCols));
colormap([1 1 1;1 0 0;0 1 0;0 0 1]);
title('Block ICM Decoding of Noisy X');
fprintf('(paused)\n');
pause

%% Alpha-Beta Decode

alphaBetaDecode = UGM_Decode_AlphaBetaSwap(nodePot,edgePot,edgeStruct,@UGM_Decode_GraphCut,ICMDecoding);

figure(5);
imagesc(reshape(alphaBetaDecode,nRows,nCols));
colormap([1 1 1;1 0 0;0 1 0;0 0 1]);
title('Alpha-Beta Swap Decoding of Noisy X');
fprintf('(paused)\n');
pause