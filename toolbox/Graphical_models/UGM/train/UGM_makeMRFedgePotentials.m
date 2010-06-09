function [edgePot] = UGM_makeEdgePotentials(v,edgeStruct,infoStruct)
% Makes pairwise class potentials for each node
%
% Xedge(1,feature,edge)
% v(feature,variable,variable) - edge weights
% nStates - number of States per node
%
% edgePot(class1,class2,edge)

edgePot = UGM_makeCRFEdgePotentials(ones(1,1,edgeStruct.nEdges),v,edgeStruct,infoStruct);
