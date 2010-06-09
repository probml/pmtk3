function [w] = L1groupSPG(funObj,w,lambda,groups,options)
% Note: recently changed order of groups and lambda input variables

if nargin < 5
    options = [];
end

normType = myProcessOptions(options,'normType',2);

nVars = length(w);
nGroups = length(unique(groups(groups>0)));

% Make initial values for auxiliary variables
wAlpha = [w;zeros(nGroups,1)];
for g = 1:nGroups
    if normType == 2
        wAlpha(nVars+g) = norm(w(groups==g));
    else
        if any(groups==g)
            wAlpha(nVars+g) = max(abs(w(groups==g)));
        end
    end
end

% Make Objective and Projection Function
wrapFunObj = @(w)auxGroupLoss(w,groups,lambda,funObj);
[groupStart,groupPtr] = groupl1_makeGroupPointers(groups);
if normType == 2
    funProj = @(w)auxGroupL2Project(w,nVars,groupStart,groupPtr);
else
    funProj = @(w)auxGroupLinfProject(w,nVars,groupStart,groupPtr);
end

% Apply SPG
wAlpha = minConf_SPG(wrapFunObj,wAlpha,funProj,options);

w = wAlpha(1:nVars);
