function model = mrf2FitStruct(y, varargin)
% Fit pairwise MRF using group L1 on the edge weights
% 
% Input:
% y: Ncases * Nnodes (1,2,.., Nstates)
% 
% Optional inputs:
%
% lambdaNode L2 strength
% lambdaEdge L1 strength
%
% OUTPUT:
% model is same as crf2FitStruct
%
% Uses code from http://www.cs.ubc.ca/~murphyk/Software/L1CRF/index.html



% This file is from pmtk3.googlecode.com


[nCases nNodes] = size(y);
nEdges = nNodes*(nNodes-1)/2;
% In mrf case, we have no features
Xnode = zeros(nCases, 0, nNodes);
Xedge = zeros(nCases, 0, nEdges);

if nunique(y(:))==2
  edgePenaltyType = 'L1'; % vanilla L1 for binary
else
  edgePenaltyType = 'L1-L2'; % group L1
end

model = crf2FitStruct(y, Xnode, Xedge, 'edgePenaltyType', edgePenaltyType, ...
  varargin{:});
  
end
