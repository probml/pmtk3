function [TF, Z] = tabularFactorNormalize(TF)
% Normalize a tabular factor
[TF.T, Z] = normalize(TF.T);
end