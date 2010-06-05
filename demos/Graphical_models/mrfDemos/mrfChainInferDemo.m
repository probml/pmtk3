%% Demonstrate inference in undirected markov chain
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/chain.html

%% Setup model
nNodes = 60;
adj = chainAdjMatrix(nNodes);
nStates = 7;

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

method = 'Chain';
%method = 'Tree';
model = mrfCreate(adj, nStates, 'nodePot', nodePot, 'edgePot', edgePot, ...
  'method', method);
  
%% Unconditional inference

map =  mrfEstJoint(model)

[nodeBel, edgeBel, logZ] =  mrfInferMarginals(model);
nodeBel

setSeed(0);
samples = mrfSample(model, 100);
figure; imagesc(samples); colorbar;

%% Conditional inference
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/condition.html

clamped = zeros(nNodes,1);
clamped(10) = 6;

map =  mrfEstJoint(model, clamped)

[nodeBel, edgeBel, logZ] =  mrfInferMarginals(model, clamped);
nodeBel

setSeed(0);
samples = mrfSample(model, 100, clamped);
figure; imagesc(samples); colorbar;

