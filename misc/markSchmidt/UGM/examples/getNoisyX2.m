
clear all
close all
load X.mat
[nRows,nCols] = size(X);

y = 2-X;
ysub = y(1:16,1:16);
ysub(ysub==2) = 3;
y(1:16,1:16) = ysub;
ysub = y(1:16,17:end);
ysub(ysub==2) = 4;
y(1:16,17:end) = ysub;

Xrgb = ones(nRows,nCols,3);
Xrgb(:,:,2) = Xrgb(:,:,2) - (y==2);
Xrgb(:,:,3) = Xrgb(:,:,3) - (y==2);
Xrgb(:,:,1) = Xrgb(:,:,1) - (y==3);
Xrgb(:,:,3) = Xrgb(:,:,3) - (y==3);
Xrgb(:,:,1) = Xrgb(:,:,1) - (y==4);
Xrgb(:,:,2) = Xrgb(:,:,2) - (y==4);

figure(1);
imagesc(Xrgb);
title('Original X');


figure(2);
Xrgb = Xrgb + randn(size(Xrgb))/2;
if(exist('imshow')~=0)
imshow(Xrgb);
end
title('Noisy X');

%% Represent denoising as UGM

[nRows,nCols] = size(X);
nNodes = nRows*nCols;
nStates = 4;

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

%% Set up learning problem
y = reshape(y,[1 1 nNodes]);
X = zeros(1,3,nNodes);
X(1,1,:) = reshape(Xrgb(:,:,1),1,1,nNodes);
X(1,2,:) = reshape(Xrgb(:,:,2),1,1,nNodes);
X(1,3,:) = reshape(Xrgb(:,:,3),1,1,nNodes);
tied = 1;
X = UGM_standardizeCols(X,tied);
Xedge = UGM_makeEdgeFeaturesInvAbsDif(X,edgeStruct.edgeEnds);
X = [ones(1,1,nNodes) X];
Xedge = [ones(1,1,edgeStruct.nEdges) Xedge];
ising = 1;
infoStruct = UGM_makeCRFInfoStruct(X,Xedge,edgeStruct,ising,tied);
[w,v] = UGM_initWeights(infoStruct);
wv = [w(:);v(:)];
UB = inf(size(wv));
LB = -inf(size(wv));
LB(end-length(v(:))+1:end) = 0;
funObj = @(wv)UGM_CRFpseudoLoss(wv,X,Xedge,y,edgeStruct,infoStruct);
wv = minConf_TMP(funObj,wv,LB,UB);
[w,v] = UGM_splitWeights(wv,infoStruct);
nodePot = UGM_makeCRFNodePotentials(X,w,edgeStruct,infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
