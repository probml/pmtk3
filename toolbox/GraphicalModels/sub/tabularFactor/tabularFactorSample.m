function S = tabularFactorSample(TF, n)
% Sample from a tabular factor

% This file is from pmtk3.googlecode.com

if nargin < 2, n = 1; end
S = ind2subv(TF.sizes, sampleDiscrete(TF.T(:), n, 1));


end
