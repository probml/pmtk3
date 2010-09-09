function [TF, Z] = tabularFactorNormalize(TF)
% Normalize a tabular factor

% This file is from pmtk3.googlecode.com

[TF.T, Z] = normalize(TF.T);
end
