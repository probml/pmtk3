function [infoStruct] = UGM_makeMRFInfoStruct(edgeStruct,ising,tied)
% function [infoStruct] = UGM_makeInfoStruct(edgeStruct,ising,tied)

infoStruct = UGM_makeCRFInfoStruct(ones(1,1,edgeStruct.nNodes),ones(1,1,edgeStruct.nEdges),edgeStruct,ising,tied);