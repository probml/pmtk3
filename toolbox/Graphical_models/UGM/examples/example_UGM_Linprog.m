%% Make noisy X
getNoisyXsmall

%% ICM

fprintf('Decoding with ICM...\n');
ICMDecoding = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);

figure(3);
imagesc(reshape(ICMDecoding,nRows,nCols));
colormap gray
title('ICM Decoding of Noisy X Arm');
fprintf('(paused)\n');
pause

%% Integer Programming

fprintf('Decoding with Integer Programming...\n');
intProgDecoding = UGM_Decode_IntProg(nodePot,edgePot,edgeStruct);

figure(4);
imagesc(reshape(intProgDecoding,nRows,nCols));
colormap gray
title('Integer Programming Decoding of Noisy X Arm');
fprintf('(paused)\n');
pause

%% Linear Programming

fprintf('Decoding with Linear Programming...\n');
linProgDecoding = UGM_Decode_LinProg(nodePot,edgePot,edgeStruct);

figure(5);
imagesc(reshape(linProgDecoding,nRows,nCols));
colormap gray
title('Linear Programming Decoding of Noisy X Arm');
fprintf('(paused)\n');
pause