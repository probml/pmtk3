function model = mrfCreate(adj, nStates, varargin)
% Make a Markov random field with pairwise potentials
% Wrapper to Mark Schmidt's UGM library
% available from http://www.cs.ubc.ca/~schmidtm/Software/UGM
%
% model = mrfCreate(adj, nstates, 'nodePot', nodePot, 'edgePot', edgePot, ...
%                    'method', methodName, 'methodArgs', {})
%  adj(i,j) if there is an i-j edge 
%
% Optional arguments
%  nStates(i) number of discrete values (default 1)
%  nodePot(i,:) potential for node i (default random)
%  edgePot(:,:,e) potential for edge e (default random)
%     If you just specify a K*K matrix, it will be replicated across edges
%
%  method - name of inference engine, can be one of
%    Exact: brute force, does not scale
%    Chain: dynamic programming, assumes graph is chain
%    Tree: dynamic programming, assumes graph is a simple tree
%    Cutset: cutset conditioning, must specify cutset by hand
%    GraphCut: binary states only, MAP estimation only
%    ICM: iterative conditional modes (coordinate descent)
%    ICMrestart: ICM with multiple restarts
%    IntProg: integer programming, does not scale
%
%  methodArgs is an optional cell array passed to the method

[nodePot, edgePot, method, methodArgs] = process_options(varargin, ...
  'nodePot', [], 'edgePot', [], 'method', 'Exact', 'methodArgs', {});

model.adj = adj;
model.nStates = nStates;
model.edgeStruct = UGM_makeEdgeStruct(adj,nStates);
model.infFun = str2func(sprintf('UGM_Infer_%s', method));
model.decodeFun = str2func(sprintf('UGM_Decode_%s', method));
model.sampleFun = str2func(sprintf('UGM_Sample_%s', method));
model.methodArgs = methodArgs;

% Make random potentials, if necessary
model.nNodes = size(adj, 1);
edgeEnds = model.edgeStruct.edgeEnds;
model.nEdges = size(edgeEnds,1);
K = max(nStates);
if isempty(nodePot)
  nodePot = zeros(model.nNodes, K);
  for i=1:model.nNodes
    nodePot(i,:) = rand(1,nstates(i));
  end
end
if isempty(edgePot)
  edgePot = zeros(K, K, model.nEdges);
  for e=1:model.nEdges
     n1 = edgeEnds(e,1);
     n2 = edgeEnds(e,2);
    edgePot(:,:,e) = rand(nstates(n1), nstates(n2));
  end
elseif size(edgePot,3)==1
  % replicate edge potential
   edgePot = repmat(edgePot, [1 1 model.nEdges]);
end

model.nodePot = nodePot;
model.edgePot = edgePot;

end
