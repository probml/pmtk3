function [model, loglikHist] = mixModelFit(data, nmix, type, varargin)
%% Fit a mixture model
%
%%
[model, loglikHist] = mixModelFitEm(data, nmix, type, varargin{:});
end