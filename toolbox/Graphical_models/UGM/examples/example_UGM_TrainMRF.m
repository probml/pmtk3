%%
clear all
close all
load rain.mat
y = X+1; % Convert from {0,1} to {1,2} representation

% Plot what data looks like
figure(1);
imagesc(y(1:100,:))
title('Rain Data for first 100 months');

% Compute marginal of raining on any day
p_rain = sum(y(:)==2)/numel(y)

% Compute log-likelihood of full data set
negloglik_y = log(p_rain)*sum(y(:)==2) + log(1-p_rain)*sum(y(:)==1)

% Plot what independent samples would look like
figure(2);
imagesc(p_rain > rand(100,28));
title('Samples based on independent model');
fprintf('(paused)\n');
pause

%% Make edgeStruct
[nInstances,nNodes] = size(y);
nStates = max(y);
adj = zeros(nNodes);
for i = 1:nNodes-1
    adj(i,i+1) = 1;
end
adj = adj+adj';
edgeStruct = UGM_makeEdgeStruct(adj,nStates);

%% Training (Ising = 1)

% Make infoStruct
tied = 1;
ising = 1;
infoStruct = UGM_makeMRFInfoStruct(edgeStruct,ising,tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

% Example of making potentials
nodePot = UGM_makeMRFnodePotentials(w,edgeStruct,infoStruct);
edgePot = UGM_makeMRFedgePotentials(v,edgeStruct,infoStruct);
nodePot(1,:)
edgePot(:,:,1)

% Make Objective function
wv = [w(:);v(:)];
inferFunc = @UGM_Infer_Chain;
funObj = @(wv)UGM_MRFLoss(wv,y,edgeStruct,infoStruct,inferFunc);

% Optimize
[wv] = minFunc(funObj,wv);
[w,v] = UGM_splitWeights(wv,infoStruct);

% Now make potentials
nodePot = UGM_makeMRFnodePotentials(w,edgeStruct,infoStruct);
edgePot = UGM_makeMRFedgePotentials(v,edgeStruct,infoStruct);
nodePot(1,:)
edgePot(:,:,1)
fprintf('(paused)\n');
pause

%% Training (Ising = 2)

% Make infoStruct
tied = 1;
ising = 2;
infoStruct = UGM_makeMRFInfoStruct(edgeStruct,ising,tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

% Make Objective function
wv = [w(:);v(:)];
inferFunc = @UGM_Infer_Chain;
funObj = @(wv)UGM_MRFLoss(wv,y,edgeStruct,infoStruct,inferFunc);

% Optimize
[wv] = minFunc(funObj,wv);
[w,v] = UGM_splitWeights(wv,infoStruct);

% Now make potentials
nodePot = UGM_makeMRFnodePotentials(w,edgeStruct,infoStruct);
edgePot = UGM_makeMRFedgePotentials(v,edgeStruct,infoStruct);
nodePot(1,:)
edgePot(:,:,1)
fprintf('(paused)\n');
pause

%% Training (Ising = 0)

% Make infoStruct
tied = 1;
ising = 0;
infoStruct = UGM_makeMRFInfoStruct(edgeStruct,ising,tied);

% Initialize weights
[w,v] = UGM_initWeights(infoStruct);

% Make Objective function
wv = [w(:);v(:)];
inferFunc = @UGM_Infer_Chain;
funObj = @(wv)UGM_MRFLoss(wv,y,edgeStruct,infoStruct,inferFunc);

% Optimize
[wv] = minFunc(funObj,wv);
[w,v] = UGM_splitWeights(wv,infoStruct);

% Now make potentials
nodePot = UGM_makeMRFnodePotentials(w,edgeStruct,infoStruct);
edgePot = UGM_makeMRFedgePotentials(v,edgeStruct,infoStruct);
nodePot(1,:)
edgePot(:,:,1)
fprintf('(paused)\n');
pause

%% Do decoding/infence/sampling in learned model

decode = UGM_Decode_Chain(nodePot,edgePot,edgeStruct)

[nodeBel,edgeBel,logZ] = UGM_Infer_Chain(nodePot,edgePot,edgeStruct);
nodeBel

samples = UGM_Sample_Chain(nodePot,edgePot,edgeStruct);
figure(3);
imagesc(samples')
title('Samples from MRF model');
fprintf('(paused)\n');
pause

%% Do conditional decoding/inference/sampling in learned model

clamped = zeros(nNodes,1);
clamped(1:2) = 2;

condDecode = UGM_Decode_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Decode_Chain)
condNodeBel = UGM_Infer_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Infer_Chain)
condSamples = UGM_Sample_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Sample_Chain);

figure(4);
imagesc(condSamples')
title('Conditional samples from MRF model');
fprintf('(paused)\n');
pause