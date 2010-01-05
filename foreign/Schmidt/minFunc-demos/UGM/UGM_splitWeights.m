function [w,v] = UGM_splitWeights(wv,infoStruct)
% [w,v] = UGM_splitWeights(wv,infoStruct)
wSize = infoStruct.wSize;
vSize = infoStruct.vSize;
wLinInd = infoStruct.wLinInd;
vLinInd = infoStruct.vLinInd;
wLength = length(wLinInd);

w = zeros(wSize);
w(wLinInd) = wv(1:wLength);
v = zeros(vSize);
v(vLinInd) = wv(wLength+1:end);