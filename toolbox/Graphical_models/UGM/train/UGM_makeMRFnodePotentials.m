function [nodePot] = UGM_makeMRFnodePotentials(w,edgeStruct,infoStruct)
% Makes class potentials for each node
%
% w(feature,variable,variable) - node weights
% nStates - number of states per node
%
% nodePot(node,class)

nodePot = UGM_makeCRFNodePotentials(ones(1,1,edgeStruct.nNodes),w,edgeStruct,infoStruct);