function [nodePot] = UGM_makeCRFnodePotentials(X,w,edgeStruct,infoStruct)
% [nodePot] = UGM_makeCRFnodePotentials(X,w,edgeStruct,infoStruct)
% Makes class potentials for each node
%
% X(1,feature,node)
% w(feature,variable,variable) - node weights
% nStates - number of states per node
%
% nodePot(node,class)

if edgeStruct.useMex
   % Mex Code
   nNodes = size(X,3);
   nStates = edgeStruct.nStates;
   nodePot = UGM_makeNodePotentialsC(X,w,int32(nStates),int32(infoStruct.tieNodes));
else
   % Matlab Code
   nodePot = makeNodePotentials(X,w,edgeStruct,infoStruct);
end
end

% C code does the same as below:
function [nodePot] = makeNodePotentials(X,w,edgeStruct,infoStruct)

[nInstances,nFeatures,nNodes] = size(X);
tied = infoStruct.tieNodes;
nStates = edgeStruct.nStates;

if tied
    nw = w;
end

% Compute Node Potentials
nodePot = zeros(nNodes,max(nStates),nInstances);
for i = 1:nInstances
   for n = 1:nNodes
      if ~tied
         nw = w(:,1:nStates(n)-1,n);
      end
      nodePot(n,1:nStates(n),i) = exp([X(i,:,n)*nw 0]);
   end
end
end
