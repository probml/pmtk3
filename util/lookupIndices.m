function ndx = lookupIndices(small, big)
% ndx(i) = location of small(i) in big
% e.g., small=[8,2], big=[2,4,8,7], ndx = [3 1]

if isempty(intersectPMTK(small, big))
  ndx = []; return;
end
n = numel(small);
ndx = zeros(n,1);
for i=1:n
  ndx(i) = find(big==small(i));
end
% loop is faster than vectorized versions 
% ndx = any(bsxfun(@eq,smalldom',bigdom),1)
%     or
% [junk,ndx] = ismember(smalldom,bigdom);