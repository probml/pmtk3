%% Demonstrate inference in undirected markov chain
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/chain.html

% This file is from pmtk3.googlecode.com


%% Setup model
nNodes = 60;
adj = chainAdjMatrix(nNodes);
nStates = 7*ones(1,nNodes);

initial = [.3 .6 .1 0 0 0 0];
nodePot = zeros(nNodes,nStates);
nodePot(1,:) = initial;
nodePot(2:end,:) = 1;

edgePot = [.08 .9 .01 0 0 0 .01
  .03 .95 .01 0 0 0 .01
  .06 .06 .75 .05 .05 .02 .01
  0 0 0 .3 .6 .09 .01
  0 0 0 .02 .95 .02 .01
  0 0 0 .01 .01 .97 .01
  0 0 0 0 0 0 1];

% Conditional inferenec fails using Chain due to a bug
%method = 'Chain';
method = 'Tree';
model = mrf2Create(adj, nStates, 'nodePot', nodePot, 'edgePot', edgePot, ...
  'method', method);
  
%% Unconditional inference

map =  mrf2Map(model)

[nodeBel, edgeBel, logZ] =  mrf2InferNodesAndEdges(model);

setSeed(0);
samples = mrf2Sample(model, 100);
figure; imagesc(samples); colorbar;

%% Conditional inference
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/condition.html

clamped = zeros(nNodes,1);
clamped(10) = 6;

map =  mrf2Map(model, clamped)

[nodeBel, edgeBel, logZ] =  mrf2InferNodesAndEdges(model, clamped);

setSeed(0);
samples = mrf2Sample(model, 100, clamped);
figure; imagesc(samples); colorbar;

