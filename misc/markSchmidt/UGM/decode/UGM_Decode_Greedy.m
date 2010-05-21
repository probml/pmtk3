function  [y] = UGM_Infer_Greedy(nodePot, edgePot, edgeStruct,y)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)

[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

if nargin < 4
% Initialize
[junk y] = max(nodePot,[],2);
end

while 1
    for n = 1:nNodes

        % Compute Node Potential
        pot = nodePot(n,1:nStates(n));

        % Find Neighbors
        edges = E(V(n):V(n+1)-1);

        % Multiply Edge Potentials
        for e = edges(:)'
            n1 = edgeEnds(e,1);
            n2 = edgeEnds(e,2);

            if n == edgeEnds(e,1)
                ep = edgePot(1:nStates(n1),y(n2),e)';
            else
                ep = edgePot(y(n1),1:nStates(n2),e);
            end
            pot = pot .* ep;
        end

        % Compute Difference between current state and move to best state
        [difference(n) bestMove(n)] = max(pot/pot(y(n)));
    end
    
    if max(difference) <= 1
        break;
    else
        [junk maxInd] = max(difference);
        y(maxInd) = bestMove(maxInd);
    end

end