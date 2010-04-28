function [Ximpute, model] = imputeGmm(Xmiss, K, varargin)
% Impute NaN entries in Xmiss using a Gaussian mixture model
% Optional arguments are the same as mixGaussMissingFitEm
if nargin < 2, K = 5; end
model = mixGaussMissingFitEm(Xmiss, K, varargin{:});
Ximpute = mixGaussImpute(model, Xmiss);
end
