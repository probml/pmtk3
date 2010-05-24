function [TQ] = tabularFactorConditional(TF, queryVars, visVars, visValues)
%% Condition a tabular factor 
TF = tabularFactorSlice(TF, visVars, visValues);
TF = tabularFactorNormalize(TF);
TQ = tabularFactorMarginalize(TF, queryVars);
end