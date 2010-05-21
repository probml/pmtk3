%% Load Noisy X
clear all
close all

load X.mat
[nRows,nCols] = size(X);
nNodes = nRows*nCols;
nStates = 2;
nInstances = 100;

% Make 100 noisy X instances
y = 1+X;
y = reshape(y,[1 1 nNodes]);
y = repmat(y,[nInstances 1 1]);
X = y + randn(size(y))/2;

figure(1);
for i = 1:4
subplot(2,2,i);
imagesc(reshape(X(i,1,:),nRows,nCols));
colormap gray
end
suptitle('Examples of Noisy Xs');

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
Xnode = [ones(nInstances,1,nNodes) UGM_standardizeCols(X,tied)];

% Make Xedge
sharedFeatures = [1 0];
Xedge = UGM_makeEdgeFeatures(Xnode,edgeStruct.edgeEnds,sharedFeatures);
infoStruct = UGM_makeCRFInfoStruct(Xnode,Xedge,edgeStruct,ising,tied);

%% Evaluate with random parameters

figure(2);
    [w,v] = UGM_initWeights(infoStruct,@randn);
for i = 1:4
    subplot(2,2,i);
    nodePot = UGM_makeCRFNodePotentials(Xnode,w,edgeStruct,infoStruct);
    edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
    nodeBel = UGM_Infer_LBP(nodePot(:,:,i),edgePot(:,:,:,i),edgeStruct);
    imagesc(reshape(nodeBel(:,2),nRows,nCols));
    colormap gray
end
suptitle('Loopy BP node marginals with random parameters');
fprintf('(paused)\n');
pause

%% Train with Loopy Belief Propagation for 3 iterations

[w,v] = UGM_initWeights(infoStruct);
wv = [w(infoStruct.wLinInd);v(infoStruct.vLinInd)];
options.maxFunEvals = 3;
funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct,@UGM_Infer_LBP);
wv = minFunc(funObj,wv,options);
[w,v] = UGM_splitWeights(wv,infoStruct);

figure(3);
for i = 1:4
    subplot(2,2,i);
    nodePot = UGM_makeCRFNodePotentials(Xnode,w,edgeStruct,infoStruct);
    edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
    nodeBel = UGM_Infer_LBP(nodePot(:,:,i),edgePot(:,:,:,i),edgeStruct);
    imagesc(reshape(nodeBel(:,2),nRows,nCols));
    colormap gray
end
suptitle('Loopy BP node marginals with truncated minFunc parameters');
fprintf('(paused)\n');
pause

%% Train with Stochastic gradient descent for the same amount of time
maxIter = nInstances*options.maxFunEvals;
stepSize = 1e-4;
[w,v] = UGM_initWeights(infoStruct);
wv = [w(infoStruct.wLinInd);v(infoStruct.vLinInd)];
for iter = 1:maxIter
    i = ceil(rand*nInstances);
    funObj = @(wv)UGM_CRFLoss(wv,Xnode(i,:,:),Xedge(i,:,:),y(i,:),edgeStruct,infoStruct,@UGM_Infer_LBP);
    [f,g] = funObj(wv);
    
    fprintf('Iter = %d of %d (fsub = %f)\n',iter,maxIter,f);
    
    wv = wv - stepSize*g;
end
[w,v] = UGM_splitWeights(wv,infoStruct);

figure(4);
for i = 1:4
    subplot(2,2,i);
    nodePot = UGM_makeCRFNodePotentials(Xnode,w,edgeStruct,infoStruct);
    edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
    nodeBel = UGM_Infer_LBP(nodePot(:,:,i),edgePot(:,:,:,i),edgeStruct);
    imagesc(reshape(nodeBel(:,2),nRows,nCols));
    colormap gray
end
suptitle('Loopy BP node marginals with truncated  stochastic gradient parmaeters');
fprintf('(paused)\n');
pause


