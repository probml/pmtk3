function [params1,params2,graphScores,evals] =  LassoOrderGetSwapParams(X,order,swaps,complexityFactor,discrete,clamped,PP)
% returns vector output
% swaps is a vector of first position of swaps to evaluate
%
% This function and OrderSearchDAGEvaluate need to be refactored
%   to avoid redundency

[n,p] = size(X);
graphScores = zeros(p-1,2);
params1 = cell(p-1,1);
params2 = cell(p-1,1);
evals = 0;


for i = swaps
    if i > p-1 || i < 1
        % illegal swap
        continue;
    end
    
    new_order = order([1:i-1 i+1 i i+2:p]);
    
    % ===========================================
    % compute 1st element of swap (i)
    % ===========================================
    if discrete == 1
        yvar = sign(X(clamped(:,new_order(i))==0,new_order(i))-.5);
    else
        yvar = X(clamped(:,new_order(i))==0,new_order(i));
    end
    
    % Compute legal parents
    LPOrder = new_order(1:i-1);
    LPCondD = find(PP(:,new_order(i)));
    [LP LPind] = intersect(LPOrder,LPCondD);
    
    [LPparams,familyScore,familyEvals] = OrderSearch_sub(...
        X(clamped(:,new_order(i))==0,LP),yvar,complexityFactor,discrete);
    
    coeff = zeros(i,1);
    coeff([1 LPind+1]) = LPparams;
    params1{i} = coeff;
    graphScores(i,1) = familyScore;
    evals = evals + familyEvals;
    
    % ===========================================
    % compute 2nd element of swap (i+1)
    % ===========================================
    if discrete == 1
        yvar = sign(X(clamped(:,new_order(i+1))==0,new_order(i+1))-.5);
    else
        yvar = X(clamped(:,new_order(i+1))==0,new_order(i+1));
    end
    
    LPOrder = new_order(1:i);
    LPCondD = find(PP(:,new_order(i+1)));
    [LP LPind] = intersect(LPOrder,LPCondD);
    
    [LPparams,familyScore,familyEvals] = OrderSearch_sub(...
        X(clamped(:,new_order(i+1))==0,LP),yvar,complexityFactor,discrete);
    coeff = zeros(i+1,1);
    coeff([1 LPind+1]) = LPparams;
    params2{i} = coeff;
    graphScores(i,2) = familyScore;
    evals = evals+familyEvals;
    
end