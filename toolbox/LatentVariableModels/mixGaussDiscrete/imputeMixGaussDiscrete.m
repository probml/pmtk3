function [Ximpute, model] = imputeMixGaussDiscrete(Xmiss, K, types, varargin)
% Impute NaN entries in Xmiss using a GaussDiscrete mixture model
% Optional arguments are the same as mixGaussMissingFitEm

% This file is from pmtk3.googlecode.com

if nargin < 2, K = 5; end
model = mixGaussDiscreteMissingFitEm(Xmiss, K, types, varargin{:});
Ximpute = mixGaussDiscreteImpute(model, Xmiss);
end
