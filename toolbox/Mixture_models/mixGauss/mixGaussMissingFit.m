function [model, loglikHist] = mixGaussMissingFit(data, K, varargin)
% Fit a mixture of Gaussians where the data may have NaN entries
% Set doMAP = 1 to do MAP estimation (default)
% Set diagCov = 1 to use and diagonal covariances (does not currently save
% space)
%PMTKlatentModel mixGauss
[model, loglikHist] = mixGaussMissingFitEm(data, K, varargin{:});