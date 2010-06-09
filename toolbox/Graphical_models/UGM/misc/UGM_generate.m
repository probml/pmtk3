function [nodeLabels,adjMatrix,nodeFeatures,edgeFeatures,nodeWeights,edgeWeights] = UGM_generate(nInstances,nFeatures,nNodes,adj,nStates,ising,tied,type,maxIter)
% [nodeLabels,adjMatrix,nodeFeatures,edgeFeatures,nodeWeights,edgeWeights]
% = UGM_generate(nInstances,nFeatures,nNodes,adj,nStates,ising,tied,type,maxIter)
%
% example: sampleUGM(10,5,4,.5,1,2)
%
% Samples a CRF model
%   Inputs:
%       nInstances - number of data samples to generate
%       nFeatures - number of features to use (in addition to bias)
%           (ie. generates from an MRF if nFeatures = 0, CRF if nFeatures>0)
%       nNodes - number of nodes in graph
%           (if nNodes <= 16, uses exact sampling, otherwise uses Gibbs)
%       adj - either an adjacency matrix, or scalar indicating probability
%           of randomly adding an edge between nodes
%       tied - if 1, all nodes/edges share the same weights
%              if 0, each node and edge has its own weights
%       classes - number of classes (>2 is less efficient)
%       type - if 1, edge weights are bounded by a random number for each
%           edge, otherwise the edge weights are random
%       maxIter - number of iterations for Gibbs sampling
%
%   Outputs:
%       adjMatrix(nNodes,nNodes) - 1 if an edge exists between i and j
%       nodeFeatures(nInstances,nFeatures+1,nNodes) - features for each node
%       edgeFeatures(nInstances,nFeatures*2+1,nEdges) - features for each edge
%       nodeWeights(nFeatures+1,variable) - node weights
%       edgeWeights(nFeatures*2+1,variable) - edge weights
%       nodeLabels(nInstances,nNodes) - node labels
%
%   - node features are generated from N(0,1)
%   - edge features are the union of node features
%   - node weights are sampled from N(0,1)
%   - edge weights are sampled from N(0,1)
%   - labels are sampled from the CRF distribution

if nargin < 8
   type = 0;
end
if nargin < 9
    maxIter = 1000;
end

% If adj is a scalar, randomly add edges with probability adj
%   otherwise, use adj as the adjacency matrix
if isscalar(adj)
    edgeProb = adj;
    adjMatrix = zeros(nNodes);
    for i = 1:nNodes
        for j = i+1:nNodes
            if rand < edgeProb
                adjMatrix(i,j) = 1;
                adjMatrix(j,i) = 1;
            end
        end
    end
else
    adjMatrix = adj;
end

% Make edges from adjacency matrix
useMex = 1;
edgeStruct=UGM_makeEdgeStruct(adjMatrix,nStates,useMex,maxIter);
V = edgeStruct.V;
E = edgeStruct.E;
edgeEnds = edgeStruct.edgeEnds;
nEdges = size(edgeEnds,1);

% Generate Node Features
nodeFeatures = randn(nInstances,nFeatures,nNodes);

% Compute Edge Features (just uses node features from both nodes)
edgeFeatures = UGM_makeEdgeFeatures(nodeFeatures,edgeEnds);

% Add bias elements
nodeFeatures = [ones(nInstances,1,nNodes) nodeFeatures];
edgeFeatures = [ones(nInstances,1,nEdges) edgeFeatures];

% Make infoStruct
infoStruct = UGM_makeCRFInfoStruct(nodeFeatures,edgeFeatures,edgeStruct,ising,tied);

% Generate Random Node and Edge Weights
[nodeWeights,edgeWeights] = UGM_initWeights(infoStruct,@randn);
nodeWeights=nodeWeights*2;
if type == 1
    if tied
            maxWeight = randn*2;
            edgeWeights = sign(rand(size(edgeWeights))-.5).*rand(size(edgeWeights))*maxWeight;
    else
        for e = 1:nEdges
            maxWeight = randn*2;
            edgeWeights(:,:,e) = sign(rand(size(edgeWeights(:,:,e)))-.5).*rand(size(edgeWeights(:,:,e)))*maxWeight;
        end
    end
elseif type == 2
    edgeWeights = sign(rand(size(edgeWeights))-.5) + randn(size(edgeWeights))/4;
else
    edgeWeights = edgeWeights*2;
end

% Compute Potentials
nodePot = UGM_makeCRFNodePotentials(nodeFeatures,nodeWeights,edgeStruct,infoStruct);
edgePot = UGM_makeCRFEdgePotentials(edgeFeatures,edgeWeights,edgeStruct,infoStruct);

if nNodes <= 16
    fprintf('Exact Sampling\n');

    if nFeatures == 0
        edgeStruct.maxIter = nInstances;
        nodeLabels = UGM_Sample_Exact(nodePot(:,:,1),edgePot(:,:,:,1),edgeStruct)';
    else
        edgeStruct.maxIter = 1;
        nodeLabels = zeros(nInstances,nNodes);
        for i = 1:nInstances
            nodeLabels(i,:) = UGM_Sample_Exact(nodePot(:,:,i),edgePot(:,:,:,i),edgeStruct)';
        end
    end
else
    fprintf('Gibbs Sampling\n');
    edgeStruct.maxIter = 1;
    for i = 1:nInstances
%         if mod(i,10) == 0
%             fprintf('Generating Sample %d of %d\n',i,nInstances);
%         end
       sample = UGM_Sample_Gibbs(nodePot(:,:,i),edgePot(:,:,:,i),edgeStruct,maxIter);
       nodeLabels(i,:) = sample';
    end
end


% Remove bias in returned result
nodeFeatures = nodeFeatures(:,2:end,:);
edgeFeatures = edgeFeatures(:,2:end,:);
