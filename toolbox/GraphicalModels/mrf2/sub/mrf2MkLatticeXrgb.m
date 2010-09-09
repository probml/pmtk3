function [model] = mrf2MkLatticeXrgb(Xrgb, y, method,  methodArgs)
% Make a 2d lattice MRF suitable for denoising a particular image
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/alphaBeta.html

% This file is from pmtk3.googlecode.com


% y(i,j) in {1,2,3,4} is the true label
% Xrgb(i,j,:) is the noisy rgb vector at pixel i,j

if nargin < 3, method = 'dummy'; end
if nargin < 4, methodArgs = {}; end


[nRows,nCols,ncolors] = size(Xrgb);
nNodes = nRows*nCols;
nStates = 4;
adj = latticeAdjMatrix(nRows,nCols);

if 1
  % learn parameters using pseudo likelihood (very fast)
  % We tied the edge params v and the node params w
  % Edge params v constrained to be Ising and +ve
  % This ensures pairwise sub-modularity
  edgeStruct = UGM_makeEdgeStruct(adj,nStates);
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
options.verbose = 0;
wv = minConf_TMP(funObj,wv,LB,UB, options);
[w,v] = UGM_splitWeights(wv,infoStruct);
%{
w = 4.7805    2.7663    0.9735
    2.8626    2.7462    0.5540
    4.2560    1.8250    4.5490
   -0.5093   -4.0128   -4.1532
v' =  2.7556         0         0         0
%}
nodePot = UGM_makeCRFNodePotentials(X,w,edgeStruct,infoStruct);
edgePot = UGM_makeCRFEdgePotentials(Xedge,v,edgeStruct,infoStruct);
end

model = mrf2Create(adj, nStates, 'nodePot', nodePot, ...
  'edgePot', edgePot, 'method', method,  methodArgs{:});

end
