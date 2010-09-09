%% Test PMTK mrf code against mrf2
%
%%

% This file is from pmtk3.googlecode.com

nNodes = 60;
adj = chainAdjMatrix(nNodes);
nStates = 7*ones(1,nNodes);

initial = [.3 .6 .1 0 0 0 0];
nodePot = zeros(nNodes, max(nStates));
nodePot(1,:) = initial;
nodePot(2: end,:) = 1;

edgePot = [.08 .9 .01 0 0 0 .01
           .03 .95 .01 0 0 0 .01
           .06 .06 .75 .05 .05 .02 .01
           0 0 0 .3 .6 .09 .01
           0 0 0 .02 .95 .02 .01
           0 0 0 .01 .01 .97 .01
           0 0 0 0 0 0 1];


%% Unconditional inference
method = 'Tree';
model = mrf2Create(adj, nStates, 'nodePot', nodePot, 'edgePot', edgePot, ...
  'method', method);
  
[nodeBel, edgeBel, logZ] =  mrf2InferNodesAndEdges(model);

mrfPmtk = mrfCreate(adj, 'nodePots', mat2cellRows(nodePot), 'edgePots', edgePot); 
nodeBelPmtk  = mrfInferNodes(mrfPmtk); 
assert(approxeq(nodeBel', tfMarg2Mat(nodeBelPmtk))); 

mapMrf2 = mrf2Map(model);
mapMrf  = mrfMap(mrfPmtk);
assert(isequal(mapMrf2, mapMrf)); 
%%
setSeed(0);
samples = mrf2Sample(model, 100);


%% Conditional inference
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/condition.html

clamped = zeros(nNodes, 1);
clamped(10) = 6;

mapMrf2 =  mrf2Map(model, clamped);
mapMrf  = mrfMap(mrfPmtk, 'clamped', clamped); 
assert(isequal(mapMrf2, mapMrf)); 


[nodeBel, edgeBel, logZ] =  mrf2InferNodesAndEdges(model, clamped);
nodeBelPmtk = mrfInferNodes(mrfPmtk, 'clamped', sparse(clamped')); 

hidNodes = setdiffPMTK(1:nNodes, find(clamped)); 
for i=1:numel(hidNodes)
   h = hidNodes(i); 
   assert(approxeq(nodeBel(h, :)', nodeBelPmtk{h}.T)); 
end

