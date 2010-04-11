function [TF, Z] = tabularFactorNormalize(TF)
	[TF.T, Z] = normalize(TF.T);
end