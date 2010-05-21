%%
clear all
close all
load rain.mat

% Make rain labels y, and binary month features X
y = X+1;
[nInstances,nNodes] = size(y);

%% Make edgeStruct
nStates = max(y);
adj = zeros(nNodes);
for i = 1:nNodes-1
    adj(i,i+1) = 1;
end
adj = adj+adj';
edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nEdges = edgeStruct.nEdges;

%% Training (no features)

% Make simple bias features
Xnode = ones(nInstances,1,nNodes);
Xedge = ones(nInstances,1,nEdges);

% Make infoStruct
ising = 0;
tied = 1;
infoStruct = UGM_makeCRFInfoStruct(Xnode,Xedge,edgeStruct,ising,tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

% Make Objective function
inferFunc = @UGM_Infer_Chain;
funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct,inferFunc);

% Optimize
[wv] = minFunc(funObj,[w(:);v(:)]);
[w,v] = UGM_splitWeights(wv,infoStruct);
fprintf('(paused)\n');
pause

%% Training (with node features, but no edge features)

nFeatures = 12;
Xnode = zeros(nInstances,nFeatures,nNodes);
for m = 1:nFeatures
    Xnode(months==m,m,:) = 1;
end
Xnode = [ones(nInstances,1,nNodes) Xnode];

% Make infoStruct
infoStruct = UGM_makeCRFInfoStruct(Xnode,Xedge,edgeStruct,ising,tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

% Make Objective function
funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct,inferFunc);

% Optimize
[wv] = minFunc(funObj,[w(:);v(:)]);
[w,v] = UGM_splitWeights(wv,infoStruct);
fprintf('(paused)\n');
pause

%% Training (with edge features)

% Make edge features
sharedFeatures = 1:13;
Xedge = UGM_makeEdgeFeatures(Xnode,edgeStruct.edgeEnds,sharedFeatures);

% Make infoStruct
infoStruct = UGM_makeCRFInfoStruct(Xnode,Xedge,edgeStruct,ising,tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

% Make Objective function
funObj = @(wv)UGM_CRFLoss(wv,Xnode,Xedge,y,edgeStruct,infoStruct,inferFunc);

% Optimize
[wv] = minFunc(funObj,[w(:);v(:)]);
[w,v] = UGM_splitWeights(wv,infoStruct);
fprintf('(paused)\n');
pause

%% Do decoding/infence/sampling in learned model

% Now make potentials
nodePot = UGM_makeCRFNodePotentials(Xnode,w,edgeStruct,infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);

% We will look at a case in December
nodePot = nodePot(:,:,11);
edgePot = edgePot(:,:,:,11);

decode = UGM_Decode_Chain(nodePot,edgePot,edgeStruct)

[nodeBel,edgeBel,logZ] = UGM_Infer_Chain(nodePot,edgePot,edgeStruct);
nodeBel

samples = UGM_Sample_Chain(nodePot,edgePot,edgeStruct);
figure(1);
imagesc(samples')
title('Samples from CRF model (for December)');
fprintf('(paused)\n');
pause

%% Do conditional decoding/inference/sampling in learned model

% December 1915 is row 239
clamped = zeros(nNodes,1);
clamped(1:2) = 2;

condDecode = UGM_Decode_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Decode_Chain)
condNodeBel = UGM_Infer_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Infer_Chain)
condSamples = UGM_Sample_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Sample_Chain);

figure(2);
imagesc(condSamples')
title('Conditional samples from CRF model (for December)');
fprintf('(paused)\n');
pause

%% Now see what samples in July look like

Xnode = [1 0 0 0 0 0 0 1 0 0 0 0 0];
Xnode = repmat(Xnode,[1 1 nNodes]);
Xedge = UGM_makeEdgeFeatures(Xnode,edgeStruct.edgeEnds,sharedFeatures);

nodePot = UGM_makeCRFNodePotentials(Xnode,w,edgeStruct,infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);

samples = UGM_Sample_Chain(nodePot,edgePot,edgeStruct);
figure(3);
imagesc(samples')
title('Samples from CRF model (for July)');
fprintf('(paused)\n');
pause

%% Training with L2-regularization

% Set up regularization parameters
lambda = 10;
lambdaNode = lambda*ones(size(w));
lambdaNode(1,:) = 0; % Don't penalize bias
lambdaEdge = lambda*ones(size(v));
lambdaEdge(1,:) = 0; % Don't penalize biases
lambdaFull = [lambdaNode(:);lambdaEdge(:)];
regFunObj = @(wv)penalizedL2(wv,funObj,lambdaFull);

% Optimize
[w,v] = UGM_initWeights(infoStruct);
[wv] = minFunc(regFunObj,[w(:);v(:)]);
NLL = funObj(wv)
[w,v] = UGM_splitWeights(wv,infoStruct);