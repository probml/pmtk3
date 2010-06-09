%% Load Noisy X
clear all
close all

load X.mat

y = 1+X;

figure(1);
imagesc(X);
colormap gray
title('Original X');

figure(2);
X = X + randn(size(X))/2;
imagesc(X);
colormap gray
title('Noisy X');

[nRows,nCols] = size(X);
nNodes = nRows*nCols;
nStates = 2;
y = reshape(y,[1 1 nNodes]);
X = reshape(X,1,1,nNodes);

%% Make edgeStruct

adj = sparse(nNodes,nNodes);

% Add Down Edges
ind = 1:nNodes;
exclude = sub2ind([nRows nCols],repmat(nRows,[1 nCols]),1:nCols); % No Down edge for last row
ind = setdiff(ind,exclude);
adj(sub2ind([nNodes nNodes],ind,ind+1)) = 1;

% Add Right Edges
ind = 1:nNodes;
exclude = sub2ind([nRows nCols],1:nRows,repmat(nCols,[1 nRows])); % No right edge for last column
ind = setdiff(ind,exclude);
adj(sub2ind([nNodes nNodes],ind,ind+nCols)) = 1;

% Add Up/Left Edges
adj = adj+adj';
edgeStruct = UGM_makeEdgeStruct(adj,nStates);

%% Make Xnode, Xedge, infoStruct, initialize weights

tied = 1;
ising = 1;

% Add bias and Standardize Columns
Xnode = [ones(1,1,nNodes) UGM_standardizeCols(X,tied)];

% Make Xedge
sharedFeatures = [1 0];
Xedge = UGM_makeEdgeFeatures(Xnode,edgeStruct.edgeEnds,sharedFeatures);
infoStruct = UGM_makeCRFInfoStruct(Xnode,Xedge,edgeStruct,ising,tied);

%% Evaluate with random parameters

figure(3);
for i = 1:4
    fprintf('ICM Decoding with random parameters (%d of 4)...\n',i);
    subplot(2,2,i);
    [w,v] = UGM_initWeights(infoStruct,@randn);
    nodePot = UGM_makeCRFNodePotentials(Xnode,w,edgeStruct,infoStruct);
    edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
    yDecode = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);
    imagesc(reshape(yDecode,nRows,nCols));
    colormap gray
end
suptitle('ICM Decoding with random parameters');
fprintf('(paused)\n');
pause

%% Train with Pseudo-likelihood

[w,v] = UGM_initWeights(infoStruct);
wv = [w(infoStruct.wLinInd);v(infoStruct.vLinInd)];
funObj = @(wv)UGM_CRFpseudoLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct);
wv = minFunc(funObj,wv);
[w,v] = UGM_splitWeights(wv,infoStruct);

%% Evaluate with learned parameters

fprintf('ICM Decoding with estimated parameters...\n');
figure(4);
nodePot = UGM_makeCRFNodePotentials(Xnode,w,edgeStruct,infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
yDecode = UGM_Decode_ICM(nodePot,edgePot,edgeStruct);
imagesc(reshape(yDecode,nRows,nCols));
colormap gray
title('ICM Decoding with pseudo-likelihood parameters');
fprintf('(paused)\n');
pause

%% Now try with non-negative edge features and sub-modular restriction

sharedFeatures = [1 0];
Xedge = UGM_makeEdgeFeaturesInvAbsDif(Xnode,edgeStruct.edgeEnds,sharedFeatures);
infoStruct = UGM_makeCRFInfoStruct(Xnode,Xedge,edgeStruct,ising,tied);
[w,v] = UGM_initWeights(infoStruct);
wv = [w(infoStruct.wLinInd);v(infoStruct.vLinInd)];
UB = inf(size(wv));
LB = [-inf(size(w(infoStruct.wLinInd)));zeros(size(v(infoStruct.vLinInd)))];
funObj = @(wv)UGM_CRFpseudoLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct);
wv = minConf_TMP(funObj,wv,LB,UB);
[w,v] = UGM_splitWeights(wv,infoStruct);

fprintf('Graph Cuts Decoding with estimated parameters...\n');
figure(5);
nodePot = UGM_makeCRFNodePotentials(Xnode,w,edgeStruct,infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
yDecode = UGM_Decode_GraphCut(nodePot,edgePot,edgeStruct);
imagesc(reshape(yDecode,nRows,nCols));
colormap gray
title('GraphCut Decoding with constrained pseudo-likelihood parameters');
fprintf('(paused)\n');
pause

%% Now try with loopy belief propagation for approximate inference

[w,v] = UGM_initWeights(infoStruct);
wv = [w(infoStruct.wLinInd);v(infoStruct.vLinInd)];
funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct,@UGM_Infer_LBP);
wv = minConf_TMP(funObj,wv,LB,UB);
[w,v] = UGM_splitWeights(wv,infoStruct);

fprintf('Graph Cuts Decoding with estimated parameters...\n');
figure(6);
nodePot = UGM_makeCRFNodePotentials(Xnode,w,edgeStruct,infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
yDecode = UGM_Decode_GraphCut(nodePot,edgePot,edgeStruct);
imagesc(reshape(yDecode,nRows,nCols));
colormap gray
title('GraphCut Decoding with constrained loopy BP parameters');
fprintf('(paused)\n');
pause

