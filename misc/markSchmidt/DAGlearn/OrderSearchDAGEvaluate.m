function [parents,graphScores,evals,Tvals] = LassoOrderDAG(X,order,complexityFactor,discrete,clamped,PP)


[n,p] = size(X);

if nargin < 6
    PP = ones(p);
end

parents = {};
for i = 1:p
    %fprintf('Evaluating Node %d\n',i);
    
    if discrete == 1
        y = sign(X(clamped(:,order(i))==0,order(i))-.5);
    else
        y = X(clamped(:,order(i))==0,order(i));
    end
    
    % Old code, before potential parent pruning
    %[oldParents,oldgraphScores,oldEvals] = OrderSearch_sub(X(clamped(:,order(i))==0,order(1:i-1)),y,complexityFactor,discrete);
    
    % Compute legal parents
    LPOrder = order(1:i-1);
    LPCondD = find(PP(:,order(i)));
    [LP LPind] = intersect(LPOrder,LPCondD);
    
    % Compute parameters and scores
    if nargout >= 4
            [LPparams,graphScores(i,1),evals(i),Tvals(i,1)] = OrderSearch_sub(X(clamped(:,order(i))==0,LP),y,complexityFactor,discrete);
    else
    [LPparams,graphScores(i,1),evals(i)] = OrderSearch_sub(X(clamped(:,order(i))==0,LP),y,complexityFactor,discrete);
    end
    % Form parent parameters
    parentParams = zeros(i,1);
    parentParams([1 LPind+1]) = LPparams;
    parents{i,1} = parentParams;
end
evals = sum(evals);