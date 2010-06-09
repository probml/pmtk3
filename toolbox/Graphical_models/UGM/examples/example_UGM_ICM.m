%% Make noisy X
getNoisyX

%% Decoding with ICM

fprintf('Decoding with ICM...\n');
ICMDecoding = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);

figure(3);
imagesc(reshape(ICMDecoding,nRows,nCols));
colormap gray
title('ICM Decoding of Noisy X');
fprintf('(paused)\n');
pause

%% Decoding with Greedy

fprintf('Decoding with Greedy...\n');
greedyDecoding = UGM_Decode_Greedy(nodePot,edgePot,edgeStruct);

figure(4);
imagesc(reshape(greedyDecoding,nRows,nCols));
colormap gray
title('Greedy Decoding of Noisy X');
fprintf('(paused)\n');
pause

%% Decoding with ICM w/ restarts

nRestarts = 1000;
ICMrestartDecoding = UGM_Decode_ICMrestart(nodePot,edgePot,edgeStruct,nRestarts);

figure(5);
imagesc(reshape(ICMrestartDecoding,nRows,nCols));
colormap gray
title('ICM with Restarts Decoding of Noisy X');