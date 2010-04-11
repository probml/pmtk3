function [TQ] = tabularFactorConditional(TF, queryVars, visVars, visValues)
TF = tabularFactorSlice(TF, visVars, visValues);
TF = tabularFactorNormalize(TF);
TQ = tabularFactorMarginalize(TF, queryVars);
end