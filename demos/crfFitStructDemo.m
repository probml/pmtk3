%% Learn the structure of a small CRF using group L1 regularization
% We compare our resutls to 'example_UGMlearn' from
% http://www.cs.ubc.ca/~murphyk/Software/L1CRF/index.html

clear all
close all
display = 1; % Set to 0 if you don't want to draw the graphs

%% Parameters of Experiment
rand('state',0); randn('state',0); 
nTrain = 500; % number of examples to use for training
nTest = 1000; % number of examples to use for test
nFeatures = 5; % 10; % number of features for each node
nNodes = 10; % number of nodes
nStates = 2; % number of states that each can take
edgeProb = .5; % probability of each edge being included in the graph
edgeType = 1; % set to 0 to make the edge features normally distributed
ising = 0; % set to 1 to use ising potentials
trainType = 'pseudo'; % set to 'pseudo' for pseudo-likelihood, 'loopy' for loopy belief propagation, 'exact' for 'exact inference
testType = 'exact'; % set to 'loopy' to test with loopy belief propagation, 'exact' for exact inference
structureSeed = 0; % change this to generate different structures
trainSeed = 0; % vary seed from 0:9 to get paper results
useMex = 1; % use mex files in UGM to speed things up

% Regularization Parameters
lambdaNode = 10; 
lambdaEdge = 10;
% In the paper, we picked these two values by two-fold
% cross-validation, testing the values 2.^[7:-1:-5] for each model
% In the paper, we also used warm-starting to speed up the optimization 
%   for this sequence of values

%% Generate data
fprintf('Generating Synthetic CRF Data...\n');
rand('state',structureSeed);
randn('state',structureSeed);
nInstances = nTrain+nTest;
tied = 0;
[y,adjTrue,X] = UGM_generate(nInstances,nFeatures,nNodes,edgeProb,nStates,ising,tied,edgeType);

% X: Ncases * Nfeatures * Nnodes (real)
% y: Ncases * Nnodes (1,2)

[Ncases Nfeatures Nnodes] = size(X);
if true
  % mrf mode
  X = zeros(Ncases, 0, Nnodes);
end

rand('state',trainSeed);
randn('state',trainSeed);
perm = randperm(nInstances);
trainNdx = perm(1:nTrain);
testNdx = perm(nTrain+1:end);

if isscalar(nStates)
    nStates = repmat(nStates,[nNodes 1]);
end

%% Mark's code
subDisplay = false;
type = 'Discriminative L1: L1-L2';
edgePenaltyType = 'L1-L2'; % Train with L1 regularization on the edges
adjInit = fullAdjMatrix(nNodes);
example_UGMlearnSub % script computes adjFinal, nodeWeights, edgeWeights

%% PMTK interface
%{
useMex = 1;
edgeStruct = UGM_makeEdgeStruct(adjInit,nStates,useMex);
nEdges = size(edgeStruct.edgeEnds,1);
Xedge = UGM_makeEdgeFeatures(X, edgeStruct.edgeEnds);
%}

% If the edge prunign threshold is 0, we should get the same
% results as example_UGMlearnSub
model = crf2FitStruct(y(trainNdx,:), X(trainNdx,:,:), [], ...
  'lambdaNode', lambdaNode, 'lambdaEdge', lambdaEdge, 'thresh', 0);
approxeq(model.edgeWeights, edgeWeights)

[logZBF, nodeBelBF] = crf2InferNodes(model, X(testNdx,:,:), [], 'infMethod', 'bruteforce');
% example_UGMlearnSub assigns some global variables for each test case
approxeq(logZBF(end), logZ)
approxeq(nodeBelBF(:,:,end), nodeBel)

%% Now compare Mark's brute force inference with jtree
% We first learn a sparse model

lambdaEdge = 50;
model = crf2FitStruct(y(trainNdx,:), X(trainNdx,:,:), [], ...
  'lambdaNode', lambdaNode, 'lambdaEdge', lambdaEdge, 'thresh', 1e-1);

ndx = testNdx(1:10);

[logZBF, nodeBelBF, edgeBelBF] = crf2InferNodes(model, X(ndx,:,:), [], 'infMethod', 'bruteforce');

[logZJ, nodeBelJ, edgeBelJ, mrf] = crf2InferNodes(model, X(ndx,:,:), [], 'infMethod', 'jtree');

approxeq(nodeBelBF, nodeBelJ)
approxeq(edgeBelBF, edgeBelJ)
approxeq(logZBF, logZJ)
