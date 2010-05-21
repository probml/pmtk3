function  [nodeLabels] = UGM_Infer_Exact(nodePot, edgePot, edgeStruct)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)

assert(prod(edgeStruct.nStates) < 50000000,'Brute Force Exact Decoding not recommended for models with > 50 000 000 states');
    
if edgeStruct.useMex
    nodeLabels = UGM_Decode_ExactC(nodePot,edgePot,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates));
else
    nodeLabels = Decode_Exact(nodePot,edgePot,edgeStruct);
end

function [nodeLabels] = Decode_Exact(nodePot,edgePot,edgeStruct)

[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
nStates = edgeStruct.nStates;

% Initialize
y = ones(nNodes,1);

maxPot = -1;
while 1
    
    pot = UGM_ConfigurationPotential(y,nodePot,edgePot,edgeEnds);

    % Compare against max
    if pot > maxPot
        maxPot = pot;
        nodeLabels = y;
    end

    % Go to next y
    for yInd = 1:nNodes
        y(yInd) = y(yInd) + 1;
        if y(yInd) <= nStates(yInd)
            break;
        else
            y(yInd) = 1;
        end
    end

    % Stop when we are done all y combinations

    if  yInd == nNodes && y(end) == 1
        break;
    end
end
