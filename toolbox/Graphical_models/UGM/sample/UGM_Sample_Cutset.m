function  [samples] = UGM_Decode_Cutset(nodePot, edgePot, edgeStruct, cutset)
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
nSamples = edgeStruct.maxIter;

cutset = sort(cutset);
regVar = setdiff(1:nNodes,cutset);
nCutVars = length(cutset);

% We go through once to get global normalizing constant
y = ones(1,nCutVars);
c = 0;
while 1
    c = c+1;

    % Clamp cutset variables to y
    clamped = zeros(nNodes,1);
    clamped(cutset) = y;
    [clampedNP,clampedEP,clampedES,edgeMap] = UGM_makeClampedPotentials(nodePot, edgePot, edgeStruct, clamped);
    [clampedNB,clampedEB,clampedZ(c)] = UGM_Infer_Tree(clampedNP,clampedEP,clampedES);

    % Take into account node potentials of cutset nodes
    clampedZ(c) = exp(clampedZ(c));
    for i = 1:length(cutset)
        n = cutset(i);
        clampedZ(c) = clampedZ(c)*nodePot(n,y(i));

        % Add edge potentials of edges between cutset nodes
        %   (innefficient, you should just find these edges once...)
        edges = E(V(n):V(n+1)-1);
        for e = edges(:)'
            n1 = edgeEnds(e,1);
            n2 = edgeEnds(e,2);

            if n == edgeEnds(e,1) && ismember(n1,cutset) && ismember(n2,cutset)
                cutVar1 = find(cutset==n1);
                cutVar2 = find(cutset==n2);
                clampedZ(c) = clampedZ(c)*edgePot(y(cutVar1),y(cutVar2),e);
            end
        end
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
Z = sum(clampedZ);

% We now go through again to generate samples
y = ones(1,nCutVars);
c = 0;
u = 0;
done = zeros(nSamples,1);
U = rand(nSamples,1);
samples = zeros(nNodes,nSamples);
while 1
    c = c+1;

    % Clamp cutset variables to y
    clamped = zeros(nNodes,1);
    clamped(cutset) = y;
    [clampedNP,clampedEP,clampedES,edgeMap] = UGM_makeClampedPotentials(nodePot, edgePot, edgeStruct, clamped);
    
    u = u + clampedZ(c)/Z;
    sampleNum = ~done & u > U;
    if any(sampleNum)
        clampedES.maxIter = sum(sampleNum);
        samples(cutset,sampleNum) = repmat(y',[1 sum(sampleNum)]);
        samples(regVar,sampleNum) = UGM_Sample_Tree(clampedNP,clampedEP,clampedES);
        done(sampleNum) = 1;
    end
    
    %[clampedNB,clampedEB,clampedZ(c)] = UGM_Infer_Tree(clampedNP,clampedEP,clampedES);

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

