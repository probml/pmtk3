function  [y] = UGM_Infer_ICM(nodePot, edgePot, edgeStruct)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)

if edgeStruct.useMex
   y = UGM_Decode_ICMC(nodePot,edgePot,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates),int32(edgeStruct.V),int32(edgeStruct.E));
else
   y = Infer_ICM(nodePot,edgePot,edgeStruct,edgeStruct); 
end

function [y] = Infer_ICM(nodePot,edgePot,edgeStruct)

[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

% Initialize
[junk y] = max(nodePot,[],2);

done = 0;
while ~done
    done = 1;
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

        % Assign to Maximum State
        [junk newY] = max(pot);
        if newY ~= y(n)
            y(n) = newY;
            done = 0;
        end
    end

end