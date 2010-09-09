function w = linregFitGroupLassoProj(X, y, groups, lambda, winit)
%% Fits the group lasso model

% This file is from pmtk3.googlecode.com

nVars = size(X,2);
if nargin < 5, winit = zeros(nVars,1); end
nGroups = max(groups);
lambdaVect = lambda*ones(nGroups,1);

funObj1 = @(w)SquaredError(w,X,y);
funObj2 = @(w)groupL1regularizer(w,lambdaVect,groups);
funProj = @(w,stepSize)groupSoftThreshold(w,stepSize,lambdaVect,groups);

options.verbose = 0;
w = minConf_Sep(funObj1,funObj2,winit,funProj,options);

end

function [f] = groupL1regularizer(w,lambda,groups)
f = sum(lambda.*sqrt(accumarray(groups(groups~=0),w(groups~=0).^2)));
end

function [w] = groupSoftThreshold(w,alpha,lambda,groups)
    nGroups = max(groups);
    reg = sqrt(accumarray(groups(groups~=0),w(groups~=0).^2));
    for g = 1:nGroups
        w(groups==g) = (w(groups==g)/reg(g))*max(0,reg(g)-lambda(g)*alpha);
    end
end
