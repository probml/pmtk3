function [TQ] = tabularFactorCondition(TF, queryVars, visVars, visValues)
%% Compute sum_H p(Q, H | V=v) through brute force enumeration
% See also variableElimination
TF = tabularFactorSlice(TF, visVars, visValues);
TF = tabularFactorNormalize(TF);
TQ = tabularFactorMarginalize(TF, queryVars);
end