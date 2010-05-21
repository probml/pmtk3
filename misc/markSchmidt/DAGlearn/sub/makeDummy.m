function [yDummy,dummyMap] = makeDummy(y,nStates)
% Input:
%   y(instance,node), y can go from 1:nStates (if nStates is scalar)
%                            or from 1:nStates(node) (if nStates is a vector)
%
%  Output:
%   yDummy(instance,dummyNode), where labels have been replaced with dummy
%   variables
%
%   dummyMap: original index of each dummy variable
[nInstances,nNodes] = size(y);

if isscalar(nStates)
   nStates = repmat(nStates,[nNodes 1]);
end

yDummy = zeros(nInstances,0);
dummyMap = zeros(0,1);
for n = 1:nNodes
   for s = 1:nStates(n)
      yDummy(:,end+1) = y(:,n) == s;
      dummyMap(end+1,:) = n;
   end
end