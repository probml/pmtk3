function [p] = groupLinfProj(x,tau,groups)

nGroups = max(groups);

% Compute Normalized Distances across all groups
for g = 1:nGroups
    groupVars{g} = sort([abs(x(groups==g));0],'descend');
    mx(g) = groupVars{g}(1);
    dist{g}(1,1) = 0;
    for v = 2:length(groupVars{g})
        dist{g}(v,1) = dist{g}(v-1,1) + (v-1)*(groupVars{g}(v-1)-groupVars{g}(v));
    end
end

% Check Trivial Case
if sum(mx) <= tau
    %fprintf('Trivial Case\n');
    p = x;
    return;
end

% Sort normalized distances
allDist = zeros(0,1);
for g = 1:nGroups
    allDist(end+1:end+length(dist{g}),1) = dist{g};
end
allDist = sort(allDist,'descend');
minD = 1;
maxD = length(allDist);

% Binary search for distance that brackets tau
while 1
    ind = floor((maxD+minD)/2);
    D = allDist(ind);

    for g = 1:nGroups
        tmp = max(find(dist{g} <= D));
        if isempty(tmp) || tmp == length(groupVars{g})
            mx(g) = 0;
        else
            relativePos = (D-dist{g}(tmp))/(dist{g}(tmp+1)-dist{g}(tmp));
            mx(g) = (groupVars{g}(tmp+1)-groupVars{g}(tmp))*relativePos + groupVars{g}(tmp);
        end
    end
    L1Linf = sum(mx);

    if tau < L1Linf
        % Recurse on lower partition
        %fprintf('Recursing on lower partition\n');
        maxD = ind-1;
    else
        %fprintf('Testing if this is the correct partition\n');

        if ind == length(allDist)
            fprintf('Last Element (\n');
            D2 = 0;
        else
            D2 = allDist(ind+1);
        end

        for g = 1:nGroups
            tmp = max(find(dist{g} <= D2));
            if isempty(tmp) || tmp == length(groupVars{g})
                mx2(g) = 0;
            else
                relativePos = (D2-dist{g}(tmp))/(dist{g}(tmp+1)-dist{g}(tmp));
                mx2(g) = (groupVars{g}(tmp+1)-groupVars{g}(tmp))*relativePos + groupVars{g}(tmp);
            end
        end
        L1Linf2 = sum(mx2);

        if tau > L1Linf2
            %fprintf('Recursing on upper partition\n');
            minD = ind+1;
        else
            %fprintf('We are done\n');
            break;
        end
    end
end

% Form final result
p = x;
if L1Linf2 ~= L1Linf
    mu = (tau-L1Linf)/(L1Linf2-L1Linf);
else
    mu = 0;
end
for g = 1:nGroups
    groupMax = mx(g) + mu*(mx2(g)-mx(g));

    groupVars = x(groups==g);
    violating = find(abs(groupVars) > groupMax);
    groupVars(violating) = sign(groupVars(violating))*groupMax;
    p(groups==g) = groupVars;
end