function [model, loglikHist] = mixGaussDiscreteMissingFit(data, K, types, varargin)
%% Class-conditional is product of Gaussians and multinoullis
% p(x|z=k) = prod_{j in C} N(x_j|mu_{jk},sigma_{jk}) * ...
%            prod_{j in D} discrete(x_j | beta_{jk})

% Parameter of model are:
% beta(c,j,k) = p(xj=c|z=k)
% muk(j,k), sigmak(j,k),
% mixweight
%PMTKlatentModel mixGaussDiscrete
[model, loglikHist] = mixGaussDiscreteMissingFitEm(data, K, types, varargin{:});
end