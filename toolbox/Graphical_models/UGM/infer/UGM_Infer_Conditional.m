function [nodeBel, edgeBel, logZ] = UGM_Infer_Conditional(nodePot,edgePot,edgeStruct,clamped,inferFunc)
% Do inference with observed values

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;

[clampedNP,clampedEP,clampedES,edgeMap] = UGM_makeClampedPotentials(nodePot,edgePot,edgeStruct,clamped);

[clampedNB,clampedEB,logZ] = inferFunc(clampedNP,clampedEP,clampedES);

% Construct node beliefs
nodeBel = zeros(size(nodePot));
clampedSet = find(clamped~=0);
clampVar = 1;
regulVar = 1;
for n = 1:nNodes
   if clampVar <= length(clampedSet) && n == clampedSet(clampVar)
       nodeBel(n,clamped(clampedSet(clampVar))) = 1;
       clampVar = clampVar+1;
   else
       nodeBel(n,:) = clampedNB(regulVar,:);
       regulVar = regulVar + 1;
   end
end

% Construct edge beliefs
edgeBel = zeros(size(edgePot));
for e = 1:nEdges
   n1 = edgeEnds(e,1);
   n2 = edgeEnds(e,2);
   
   if any(clampedSet==n1)
       if any(clampedSet==n2)
           % This edge is between clamped variables
           clampVar1 = find(clampedSet==n1);
           clampVar2 = find(clampedSet==n2);
           edgeBel(clamped(clampedSet(clampVar1)),clamped(clampedSet(clampVar2)),e) = 1;
       else
           % n1 is a clamped variable, n2 is a regular variable
           clampVar = find(clampedSet==n1);
           regulVar = find(mysetdiff(1:nNodes,clampedSet)==n2);
           edgeBel(clamped(clampedSet(clampVar)),:,e) = clampedNB(regulVar,:);
       end
   else
       if any(clampedSet==n2)
           % n2 is a clamped variable, n1 is a regular variable
           clampVar = find(clampedSet==n2);
           regulVar = find(mysetdiff(1:nNodes,clampedSet)==n1);
           edgeBel(:,clamped(clampedSet(clampVar)),e) = clampedNB(regulVar,:)';
       else
           % This edge was present in the clamped graph
           edgeBel(:,:,e) = clampedEB(:,:,edgeMap(e));
       end
   end
end