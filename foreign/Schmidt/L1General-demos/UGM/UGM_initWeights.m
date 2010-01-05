function [w,v,wLinInd,vLinInd] = UGM_initWeights(infoStruct,initType)
% Generates an initial weight vector
%
% X(instance,feature,node)
% Xedge(instance,feature,edge)
% infoStruct: structure containing nStates, tied, and ising
% type - 'random' or 'zero'

if strcmp(initType,'random')
    initFunc = @randn;
elseif strcmp(initType,'random2')
   initFunc = @randomUnit;
else
    initFunc = @zeros;
end

w = initFunc(infoStruct.wSize);
v = initFunc(infoStruct.vSize);

end

function [r] = randomUnit(siz)
   r = sign(rand(siz)-.5).*(1+randn(siz));
end