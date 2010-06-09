function  [nodePot,edgePot,edgeStruct,edgeMap] = UGM_makeClampedPotentials(nodePot, edgePot, edgeStruct, clamped, nodeBel)
% Returns potentials/edgeStruct/infoStruct for a modified graph where some
% nodes have been set to specific states
%
% clamped(n) - set to 0 if node n is unclamped
%            - set to k to clamp node n to state k (k in {1:nStates(n)})
%            - set to -1 to do a mean field approximation of node n
%              (nodeBel is required only if some element of clamped is -1)
%
% only nStates in infoStruct is changed
%
% edgeMap with the same number of elements as the original graph,
%   that is 0 if the edge is not present in the clamped graph,
%   and is the edge number in the clamped graph if the edge is present

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

% Absorb clamped neighbors into node potentials
nodeNum = 1;
nodeMap = zeros(nNodes,1);
for n = 1:nNodes
    if clamped(n) == 0
        edges = E(V(n):V(n+1)-1);
        for e = edges(:)'
            n1 = edgeEnds(e,1);
            n2 = edgeEnds(e,2);

            if n == edgeEnds(e,1)
                if clamped(n2) ~= 0
                    if clamped(n2) == -1
                        % Use Mean-Field approximation of n2
                        b = zeros(1,nStates(n));
                        for s2 = 1:nStates(n2)
                            b = b + nodeBel(n2,s2)*log(edgePot(1:nStates(n),s2,e))';
                        end
                        nodePot(n,1:nStates(n)) = nodePot(n,1:nStates(n)).*exp(b);
                    else
                        % Clamp n2 to Fixed State
                        nodePot(n,1:nStates(n)) = nodePot(n,1:nStates(n)).*edgePot(1:nStates(n),clamped(n2),e)';
                    end
                end
            else
                if clamped(n1) ~= 0
                    if clamped(n1) == -1
                        % Use Mean-Field approximation of n1
                        b = zeros(1,nStates(n));
                        for s2 = 1:nStates(n1)
                            b = b + nodeBel(n1,s2)*log(edgePot(s2,1:nStates(n),e));
                        end
                        nodePot(n,1:nStates(n)) = nodePot(n,1:nStates(n)).*exp(b);
                    else
                        % Clamp n1 to Fixed State
                        nodePot(n,1:nStates(n)) = nodePot(n,1:nStates(n)).*edgePot(clamped(n1),1:nStates(n),e);
                    end
                end
            end
        end

        nodeMap(n) = nodeNum;
        nodeNum = nodeNum+1;
    end
end

killedNodes = find(clamped~=0);

killedEdges = zeros(0,1);
edgeNum = 1;
edgeMap = zeros(nEdges,1);
for e = 1:nEdges
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);
    if any(killedNodes == n1) || any(killedNodes == n2)
        killedEdges(end+1,1) = e;
    else
        edgeEnds(e,1) = nodeMap(n1);
        edgeEnds(e,2) = nodeMap(n2);
        edgeMap(e) = edgeNum;
        edgeNum = edgeNum+1;
    end
end

nodePot(killedNodes,:) = [];
edgePot(:,:,killedEdges) = [];
edgeStruct.nStates(killedNodes) = [];

edgeEnds(killedEdges,:) = [];
[V,E] = UGM_makeEdgeVE(edgeEnds,nodeNum-1);

edgeStruct.nEdges = size(edgeEnds,1);
edgeStruct.edgeEnds = edgeEnds;
edgeStruct.V = V;
edgeStruct.E = E;