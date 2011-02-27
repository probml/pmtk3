%% Demonstrate training a lattice-structured CRF
% Based on http://people.cs.ubc.ca/~schmidtm/Software/UGM/trainApprox

% This file is from pmtk3.googlecode.com



%% Get  data
setSeed(0);
X = loadData('Ximg');
Xclean = X;
y = 1+X;
X = Xclean + 0.5*randn(size(Xclean));
figure; imagesc(X); colormap(gray)

[nRows,nCols] = size(X);
nNodes = nRows*nCols;
nStates = 2;
y = reshape(y,[1 1 nNodes]);
X = reshape(X,1,1,nNodes);



%% Make model
adj = latticeAdjMatrix(nRows,nCols);
tied = 1;
ising = 1;
edgeStruct = UGM_makeEdgeStruct(adj,nStates);

% Add bias and Standardize Columns
Xnode = [ones(1,1,nNodes) UGM_standardizeCols(X,tied)];
sharedFeatures = [1 0];
Xedge = UGM_makeEdgeFeatures(Xnode,edgeStruct.edgeEnds,sharedFeatures);



%% Fit by PL, decode by ICM
model = crf2Create(adj, nStates, 'ising', ising, 'tied', tied, 'method', 'ICM');
model = crf2Train(model, Xnode, Xedge, y, 'method', 'PL');
yDecode = crf2Map(model, Xnode, Xedge);

figure;
imagesc(reshape(yDecode,nRows,nCols)); colormap gray
title('ICM Decoding with pseudo-likelihood parameters');


%% Fit with submodular PL and decode with graph cuts

sharedFeatures = [1 0];
Xedge = UGM_makeEdgeFeaturesInvAbsDif(Xnode,edgeStruct.edgeEnds,sharedFeatures);
model = crf2Create(adj, nStates, 'ising', ising, 'tied', tied, 'method', 'GraphCut');
model = crf2Train(model, Xnode, Xedge, y, 'method', 'PLsubmod');

figure;
imagesc(reshape(yDecode,nRows,nCols)); colormap gray
title('GraphCut Decoding with constrained pseudo-likelihood parameters');


