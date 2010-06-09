function  [nodeLabels] = UGM_Decode_Chain(nodePot, edgePot, edgeStruct)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeBel(node,class) - marginal beliefs
% edgeBel(class,class,e) - pairwise beliefs
% logZ - negative of free energy
%
% Assumes no ties


[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
nStates = edgeStruct.nStates;
maximize = 1;

% Forward Pass
[alpha,kappa,mxState] = UGM_ChainFwd(nodePot,edgePot,nStates,maximize);

% Backward Pass
nodeLabels = zeros(nNodes,1);
[mxPot nodeLabels(nNodes)] = max(alpha(nNodes,:));
for n = nNodes-1:-1:1
   nodeLabels(n) = mxState(n+1,nodeLabels(n+1));
end