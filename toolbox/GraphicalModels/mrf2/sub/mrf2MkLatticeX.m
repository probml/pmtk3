function [model] = mrf2MkLatticeX(X, method,  methodArgs)
% Make a 2d lattice MRF suitable for denoising a particular image
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/graphCuts.html

% This file is from pmtk3.googlecode.com


if nargin < 1, method = 'dummy'; end
if nargin < 3, methodArgs = {}; end

[nRows,nCols] = size(X);
nNodes = nRows*nCols;
nStates = 2;
adj = latticeAdjMatrix(nRows,nCols);

edgeStruct = UGM_makeEdgeStruct(adj,nStates);
Xstd = UGM_standardizeCols(reshape(X,[1 1 nNodes]),1);
nodePot = zeros(nNodes,nStates);
nodePot(:,1) = exp(-1-2.5*Xstd(:));
nodePot(:,2) = 1;

% Learned optimal sub-modular parameters
edgePot = zeros(nStates,nStates,edgeStruct.nEdges);
for e = 1:edgeStruct.nEdges
  n1 = edgeStruct.edgeEnds(e,1);
  n2 = edgeStruct.edgeEnds(e,2); 
  pot_same = exp(1.8 + .3*1/(1+abs(Xstd(n1)-Xstd(n2))));
  edgePot(:,:,e) = [pot_same 1;1 pot_same];
end

model = mrf2Create(adj, nStates, 'nodePot', nodePot, ...
  'edgePot', edgePot, 'method', method,  methodArgs{:});

end
