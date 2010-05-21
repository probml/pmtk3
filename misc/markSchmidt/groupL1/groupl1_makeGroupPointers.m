function [groupStart,groupPtr,nGroups] = groupl1_makeGroupPointers(groups)
nVars = length(groups);
nGroups = max(groups);

% First Count the Number of Elemets in each Group
groupStart = zeros(nGroups+1,1);
for i = 1:nVars
    if groups(i) > 0
        groupStart(groups(i)+1) = groupStart(groups(i)+1)+1;
    end
end
groupStart(1) = 1;
groupStart = cumsum(groupStart);
% Now fill in the pointers to elements of the groups
groupPtr = zeros(nVars,1);
groupPtrInd = zeros(nGroups,1);
for i = 1:nVars
    if groups(i) > 0
        grp = groups(i);
        groupPtr(groupStart(grp)+groupPtrInd(grp)) = i;
        groupPtrInd(grp) = groupPtrInd(grp)+1;
    end
end
groupStart = int32(groupStart);
groupPtr = int32(groupPtr);