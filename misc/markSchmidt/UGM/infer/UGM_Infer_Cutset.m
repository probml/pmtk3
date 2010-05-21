function [nodeBel, edgeBel, logZ] = UGM_Infer_Cutset(nodePot,edgePot,edgeStruct,cutset)
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

nodeBel = zeros(size(nodePot));
edgeBel = zeros(size(edgePot));
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
    
    
    % Update node beliefs
    cutVar = 1;
    regVar = 1;
    for n = 1:nNodes
        if cutVar <= length(cutset) && n == cutset(cutVar)
            % Update cutset variable
            nodeBel(n,y(cutVar)) = nodeBel(n,y(cutVar)) + clampedZ(c);
            cutVar = cutVar + 1;
        else
            % Update regular variable
            nodeBel(n,:) = nodeBel(n,:) + clampedNB(regVar,:)*clampedZ(c);
            regVar = regVar + 1;
        end
    end
    
    % Update edge beliefs
    for e = 1:nEdges
       n1 = edgeEnds(e,1);
       n2 = edgeEnds(e,2);
       if ismember(n1,cutset)
           if ismember(n2,cutset)
               % This edge is between cutset variables
               cutVar1 = find(cutset==n1);
               cutVar2 = find(cutset==n2);
               edgeBel(y(cutVar1),y(cutVar2),e) = edgeBel(y(cutVar1),y(cutVar2),e) + clampedZ(c);
           else
               % n1 is a cutset variable, n2 is a regular variable
               cutVar = find(cutset==n1);
               regVar = find(setdiff(1:nNodes,cutset)==n2);
               edgeBel(y(cutVar),:,e) = edgeBel(y(cutVar),:,e) + clampedNB(regVar,:)*clampedZ(c);

           end
       else
           if ismember(n2,cutset)
                              % n2 is a cutset variable, n1 is a regular variable
                              % (this case has not been tested)
               cutVar = find(cutset==n2);
               regVar = find(setdiff(1:nNodes,cutset)==n1);
               edgeBel(:,y(cutVar),e) = edgeBel(:,y(cutVar),e) + clampedNB(regVar,:)'*clampedZ(c);

           else
               % This edge was present in the clamped graph
               clampedEdge = edgeMap(e);
               edgeBel(:,:,e) = edgeBel(:,:,e) + clampedEB(:,:,clampedEdge)*clampedZ(c);
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

% Normalize Beliefs
for n = 1:nNodes
    nodeBel(n,:) = nodeBel(n,:)/sum(nodeBel(n,:));
end

for e = 1:nEdges
    edgeBel(:,:,e) = edgeBel(:,:,e)/sum(sum(edgeBel(:,:,e)));
end

logZ = log(sum(clampedZ));


