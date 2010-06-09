function [samples] = UGM_Sample_Exact(nodePot,edgePot,edgeStruct)
% Exact sampling

assert(prod(edgeStruct.nStates) < 50000000,'Brute Force Exact Sampling not recommended for models with > 50 000 000 states');

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
nStates = edgeStruct.nStates;
maxIter=  edgeStruct.maxIter;

samples = zeros(nNodes,0);

Z = computeZ(nodePot,edgePot,edgeEnds,nStates);
for s = 1:maxIter
   samples(:,s) = sampleY(nodePot,edgePot,edgeEnds,nStates,Z);
end

end


function [Z] = computeZ(nodePot,edgePot,edgeEnds,nStates)
nEdges = size(edgePot,3);
[nNodes maxStates] = size(nodePot);

y = ones(1,nNodes);
Z = 0;
while 1
    pot = 1;

    % Nodes
    for n = 1:nNodes
        pot = pot*nodePot(n,y(n));
    end

    % Edges
    for e = 1:nEdges
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);
        pot = pot*edgePot(y(n1),y(n2),e);
    end

    % Update Z
    Z = Z + pot;

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
    if sum(y==1) == nNodes
        break;
    end
end
end


function [y] = sampleY(nodePot,edgePot,edgeEnds,nStates,Z)
[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);

y = ones(1,nNodes);
cumulativePot = 0;
U = rand;
while 1
    pot = 1;

    % Nodes
    for n = 1:nNodes
        pot = pot*nodePot(n,y(n));
    end

    % Edges
    for e = 1:nEdges
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);
        pot = pot*edgePot(y(n1),y(n2),e);
    end

    % Update cumulative potential
    cumulativePot = cumulativePot + pot;

    if cumulativePot/Z > U
        % Take this y
        break;
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

end

end