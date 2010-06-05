%% Demonstrate inference in pairwise mrf using 4 node network

%% Setup model
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/small.html

nNodes = 4;
adj = zeros(nNodes);
adj(1,2) = 1;
adj(2,1) = 1;
adj(2,3) = 1;
adj(3,2) = 1;
adj(3,4) = 1;
adj(4,3) = 1;

nStates = 2*ones(1,nNodes);
nodePot = [1 3
  9 1
  1 3
  9 1];

edgePot = [2 1 ; 1 2];

model = mrfCreate(adj, nStates, 'nodePot', nodePot, 'edgePot', edgePot);


%% Unconditional inference 

map =  mrfEstJoint(model);

[nodeBel, edgeBel, logZ] =  mrfInferMarginals(model);

setSeed(0);
samples = mrfSample(model, 100);
%figure; imagesc(samples); colormap(gray)

%% Conditional inference
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/condition.html

clamped = zeros(nNodes,1);
clamped(1) = 2;
clamped(3) = 2;

[nodeBel, edgeBel, logZ] =  mrfInferMarginals(model, clamped);
nodeBel


