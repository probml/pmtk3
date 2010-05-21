function  [yMap] = UGM_Decode_Cutset(nodePot, edgePot, edgeStruct, cutset)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)
%
% Conditioning on the cutset must separate the graph into a forest

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

cutset = sort(cutset);
nCutVars = length(cutset);
y = ones(1,nCutVars);

c = 0;
maxPot = -inf;
while 1
    c = c+1;

    clamped = zeros(nNodes,1);
    clamped(cutset) = y;
    [clampedNP,clampedEP,clampedES,edgeMap] = UGM_makeClampedPotentials(nodePot, edgePot, edgeStruct, clamped);
    clampedY = UGM_Decode_Tree(clampedNP,clampedEP,clampedES);

    % Compute joint labeling
    cutVar = 1;
    regVar = 1;
    for n = 1:nNodes
        if cutVar <= length(cutset) && n == cutset(cutVar)
            % Set cutset variable
            yTrial(n,1) = y(cutVar);
            cutVar = cutVar+1;
        else
            % Set regular variable
            yTrial(n,1) = clampedY(regVar);
            regVar = regVar+1;
        end
    end

    % Compute energy of joint labeling
    logPot = UGM_LogConfigurationPotential(yTrial,nodePot,edgePot,edgeEnds);

    if logPot > maxPot
        maxPot = logPot;
        yMap = yTrial;
    end

    % Go to next y
    for yInd = 1:nCutVars
        y(yInd) = y(yInd)+1;
        if y(yInd) <= nStates(cutset(yInd))
            break;
        else
            y(yInd) = 1;
        end
    end

    % Stop when we have done all combinations of the cutset variables
    if yInd == nCutVars && y(end) == 1
        break;
    end
end


