function model = crf2FitStruct(y, Xnode, Xedge, varargin)
% Fit pairwise CRF using group L1 on the edge weights
% 
% Input:
% y: Ncases * Nnodes (1,2,.., Nstates)
% XNode: Ncases * NnodeFeatures * Nnodes
% We add a column of 1s to Xnode internally.
% Set Xnode = NaN for MRF.
%
% Xedge: Ncases * NedgeFeatures * Nedges
%   where Nedges = Nnodes * (Nnodes-1) / 2
% You need to supply Xedge for all edges
% in adjInit, which initially is the full graph.
% if you set Xedge = NaN, itnernally we will create
% edge features by concatenating the node features for the
% adjoining ends. If Xnode=[], then Xedge = 1 for each edge,
% corresponding to a full potential.
% This way, you don't need to worry
% about specifying edge features.
% 
% Optional inputs:
%
% lambdaNode L2 strength
% lambdaEdge L1 strength
%
% OUTPUT:
% model contains
% G: adjacency matrix
% nodeWeights: (NnodeFeatures) * (Nstates-1) * Nnodes
% edgeWeights: NedgeFeatures * (Nstates^2 - 1) * Nedges
% edgestruct: info about edges
% infostruct
%
% Uses code from http://www.cs.ubc.ca/~murphyk/Software/L1CRF/index.html

%PMTKauthor Mark Schmidt
%PMTKmodified Kevin Murphy

% nodePot: Nnodes * Nstates * Ncases
% edgePot: Nstates * Nstates * Nedges * Ncases


% This file is from pmtk3.googlecode.com

[nCases nNodes] = size(y);
nStates = nunique(y);
adjInit = setdiag(ones(nNodes, nNodes), 0);

Nnodes = nNodes;
nodeNames = cellfun(@(d) sprintf('n%d', d), num2cell(1:Nnodes), 'uniformoutput', false);


[lambdaNode, lambdaEdge, adjInit, useMex, ising, tied, edgePenaltyType, thresh, ...
  nStates, nodeNames] = ...
  process_options(varargin, ...
  'lambdaNode', 1e-1, 'lambdaEdge', 1, 'adjInit', adjInit, 'useMex', 1, ...
  'ising', 0, 'tied', 0, 'edgePenaltyType', 'L1-L2', 'thresh', 1e-3, ...
  'nstates', nStates, 'nodeNames', nodeNames);

edgeStruct = UGM_makeEdgeStruct(adjInit, nStates, useMex);
nEdges = size(edgeStruct.edgeEnds,1);
if isnan(Xnode)
  Xnode = zeros(nCases, 0, nNodes);
end
if isnan(Xedge)
  Xedge = UGM_makeEdgeFeatures(Xnode, edgeStruct.edgeEnds);
  %Xedge = zeros(nCases, 0, nEdges);
end


% Add Bias
nInstances = nCases;
Xnode = [ones(nInstances,1,nNodes) Xnode];
Xedge = [ones(nInstances,1,nEdges) Xedge];

% Make infoStruct and initialize weights
infoStruct = UGM_makeCRFInfoStruct(Xnode, Xedge, edgeStruct, ising, tied);
[nodeWeights, edgeWeights] = UGM_initWeights(infoStruct,@zeros);
nVars = numel(nodeWeights)+numel(edgeWeights);

funObj_sub = @(weights)UGM_CRFpseudoLoss(weights, Xnode, Xedge, y,edgeStruct,infoStruct);

% Set up Regularizer and Train
nodePenalty = lambdaNode*ones(size(nodeWeights));
nodePenalty(1,:,:) = 0; % Don't penalize node bias
edgePenalty = lambdaEdge*ones(size(edgeWeights));

fprintf('learning structure using %s, Nnodes=%d, Nedges=%d, LamNode=%5.3f, LamEdge=%5.3f\n', ...
  edgePenaltyType, nNodes, nEdges, lambdaNode, lambdaEdge);

  
if strcmp(edgePenaltyType,'L2')
    % Train with L2-regularization on node and edge parameters
    funObj = @(weights)penalizedL2(weights,funObj_sub,[nodePenalty(:);edgePenalty(:)]);
    %options.verbose = 1;
    options.display = 'final';
    options.maxIter = 100;
    
    weights = minFunc(funObj,zeros(nVars,1), options);
elseif strcmp(edgePenaltyType,'L1')
    % Train with L2-regularization on node parameters and
    % L1-regularization on edge parameters
    funObjL2 = @(weights)penalizedL2(weights,funObj_sub,[nodePenalty(:);zeros(size(edgeWeights(:)))]); % L2 on Node Parameters
    funObj = @(weights)nonNegGrad(weights,[zeros(size(nodeWeights(:)));edgePenalty(:)],funObjL2);
   
    options.verbose = 1; 
    options.maxIter = 100;
    
    weights = minConf_TMP(funObj,zeros(2*nVars,1),zeros(2*nVars,1),inf(2*nVars,1), options);
    weights = weights(1:nVars)-weights(nVars+1:end);
else
    % Train with L2-regularization on node parameters and
    % group L1-regularization on edge parameters
    groups = zeros(size(edgeWeights));
    for e = 1:nEdges
        groups(:,:,e) = e;
    end
    nGroups = length(unique(groups(groups>0)));
    
    funObjL2 = @(weights)penalizedL2(weights,funObj_sub,[nodePenalty(:);zeros(size(edgeWeights(:)))]); % L2 on Node Parameters
    nodeGroups = zeros(size(nodeWeights));
    edgeGroups = groups;
    groups = [nodeGroups(:);edgeGroups(:)];
    
    
    funObj = @(weights)auxGroupLoss(weights,groups,lambdaEdge,funObjL2);
    [groupStart,groupPtr] = groupl1_makeGroupPointers(groups);
    if strcmp(edgePenaltyType,'L1-L2')
        funProj = @(w)auxGroupL2Project(w,nVars,groupStart,groupPtr);
    elseif strcmp(edgePenaltyType,'L1-Linf')
        funProj = @(w)auxGroupLinfProject(w,nVars,groupStart,groupPtr);
    else
        fprintf('Unrecognized edgePenaltyType %s\n', edgePenaltyType);
        pause;
    end
    options.verbose = 1; 
    options.maxIter = 100;
    
    weights = minConf_SPG(funObj,[zeros(nVars,1);zeros(nGroups,1)],funProj, options);
    weights = weights(1:nVars);
end
[nodeWeights, edgeWeights] = UGM_splitWeights(weights,infoStruct);


% Find active edges
adjFinal = zeros(nNodes);
edgeNumDense = zeros(nNodes, nNodes);
for e = 1:nEdges
  n1 = edgeStruct.edgeEnds(e,1);
  n2 = edgeStruct.edgeEnds(e,2);
  edgeNumDense(n1, n2) = e;
  if (thresh==0) || any(any(abs(edgeWeights(:,:,e)) > thresh))
    adjFinal(n1,n2) = 1;
    adjFinal(n2,n1) = 1;
  else
    %$fprintf('pruning edge %d-%d\n', n1, n2);
  end
end
G = adjFinal;

fprintf('final graph has %d edges\n', sum(G(:))/2);

% Transfer weights for surviving edges
edgeStructDense = edgeStruct; %#ok
edgeStructSparse = UGM_makeEdgeStruct(G, nStates, useMex);
nEdgesSparse = size(edgeStructSparse.edgeEnds, 1);
% edgeWeights: NedgeFeatures * (Nstates^2 - 1) * Nedges
edgeWeightsDense = edgeWeights;
[NedgeFeatures, K, nEdgesDense] = size(edgeWeightsDense); %#ok
edgeWeightsSparse = zeros(NedgeFeatures, K, nEdgesSparse);
for e=1:nEdgesSparse
  n1 = edgeStructSparse.edgeEnds(e,1);
  n2 = edgeStructSparse.edgeEnds(e,2);
  eOld = edgeNumDense(n1, n2);
  edgeWeightsSparse(:, :, e) = edgeWeightsDense(:, :, eOld);
end     

edgeWeights = edgeWeightsSparse; % rename
edgeStruct = edgeStructSparse; % rename
model = structure(G, nodeWeights, edgeWeights, edgeWeightsDense, nStates, ...
  edgeStruct, ising, tied, nStates, nodeNames);

end
