function [edgeStruct] = UGM_getEdgeStructure(adj,nStates,useMex,maxIter)
% [edgeStruct] = UGM_getEdgeStructure(adj,nStates,useMex,maxIter)
%
% adj - nNodes by nNodes adjacency matrix (0 along diagonal)
%

if nargin < 3
    useMex = 1;
end
if nargin < 4
    maxIter = 100;
end

nNodes = length(adj);
[i j] = ind2sub([nNodes nNodes],find(adj));
nEdges = length(i)/2;
edgeEnds = zeros(nEdges,2);
eNum = 0;
for e = 1:nEdges*2
   if j(e) < i(e)
       edgeEnds(eNum+1,:) = [j(e) i(e)];
       eNum = eNum+1;
   end
end

nNei = zeros(nNodes,1);
nei = zeros(nNodes,0);
for e = 1:nEdges
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);
    nNei(n1) = nNei(n1)+1;
    nNei(n2) = nNei(n2)+1;
    nei(n1,nNei(n1)) = e;
    nei(n2,nNei(n2)) = e;
end

edge = 1;
for n = 1:nNodes
    V(n) = edge;
    nodeEdges = sort(nei(n,1:nNei(n)));
    E(edge:edge+length(nodeEdges)-1,1) = nodeEdges;
    edge = edge+length(nodeEdges);
end
V(nNodes+1) = edge;

edgeStruct.edgeEnds = edgeEnds;
edgeStruct.V = V;
edgeStruct.E = E;
edgeStruct.nEdges = size(edgeEnds,1);

% Handle other arguments
if isscalar(nStates)
   nStates = repmat(nStates,[nNodes 1]);
end
edgeStruct.nStates = nStates;
edgeStruct.useMex = useMex;
edgeStruct.maxIter = maxIter;


