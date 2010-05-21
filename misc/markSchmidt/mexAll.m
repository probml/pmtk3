% minFunc
fprintf('Compiling minFunc files...\n');
mex minFunc/mcholC.c
mex minFunc/lbfgsC.c

% KPM
fprintf('Compiling KPM files...\n');
mex -IKPM KPM/max_mult.c

% DAGlearn
fprintf('Compiling DAGlearn files...\n');
mex -IDAGlearn/ancestorMatrix DAGlearn/ancestorMatrix/ancestorMatrixAddC_InPlace.c
mex -IDAGlearn/ancestorMatrix DAGlearn/ancestorMatrix/ancestorMatrixBuildC.c

% GroupL1
fprintf('Compiling groupL1 files...\n');
mex groupL1/projectRandom2C.c

% UGM
fprintf('Compiling UGM files...\n');
mex -IUGM/mex UGM/mex/UGM_makeNodePotentialsC.c
mex -IUGM/mex UGM/mex/UGM_makeEdgePotentialsC.c
mex -IUGM/mex UGM/mex/UGM_MRFLoss_subC.c
mex -IUGM/mex UGM/mex/UGM_updateGradientC.c
mex -IUGM/mex UGM/mex/UGM_PseudoLossC.c
mex -IUGM/mex UGM/mex/UGM_Decode_ICMC.c
mex -IUGM/mex UGM/mex/UGM_Loss_subC.c
mex -IUGM/mex UGM/mex/UGM_Infer_LBPC.c
mex -IUGM/mex UGM/mex/UGM_Infer_ExactC.c
mex -IUGM/mex UGM/mex/UGM_Sample_GibbsC.c
mex -IUGM/mex UGM/mex/UGM_Decode_ExactC.c
mex -IUGM/mex UGM/mex/UGM_Infer_ChainC.c
mex -IUGM/mex UGM/mex/UGM_Infer_MFC.c

% Ewout
fprintf('Compiling Ewout files...\n');
mex -IForeign/Ewout Foreign/Ewout/projectBlockL1.c Foreign/Ewout/oneProjectorCore.c Foreign/Ewout/heap.c
mex -IForeign/Ewout Foreign/Ewout/projectBlockL2.c

% crfChain
fprintf('Compiling crfChain files...\n');
mex crfChain/mex/crfChain_makePotentialsC.c
mex crfChain/mex/crfChain_inferC.c
mex crfChain/mex/crfChain_lossC2.c