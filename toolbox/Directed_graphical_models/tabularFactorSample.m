function S = tabularFactorSample(TF, n)


if nargin < 2, n = 1; end
S = ind2subv(TF.sizes, sampleDiscrete(TF.T(:), n, 1));


end