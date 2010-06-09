function [w,v] = UGM_initWeights(infoStruct,initFunc)
% [w,v,wLinInd,vLinInd] = UGM_initWeights(infoStruct,initFunc)
%
% Generates an initial weight vector
%
% X(instance,feature,node)
% Xedge(instance,feature,edge)
% infoStruct: structure containing nStates, tied, and ising
% type - 'random' or 'zero'
%
% NOTE: initFunc used to be a string, now it is a function!

if nargin < 2
    initFunc = @zeros;
end

w = initFunc(infoStruct.wSize);
v = initFunc(infoStruct.vSize);

end
