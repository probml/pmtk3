function [logp] = mixGaussLogprob(varargin)
% logp = mixGaussLogprob(model, X)
% or 
% logp = mixGaussLogprob(mu, Sigma, mixWeight, X)
%
% logp(i) = log p(X(i,:) | mu(:, i), Sigma(:, :, i), mixWeight(i))

% This file is from pmtk3.googlecode.com

if nargin == 2
  model = varargin{1};
  X = varargin{2};
else
  mu = varargin{1}; Sigma = varargin{2}; mixWeight = varargin{3}; X = varargin{4};
  model = mixGaussCreate(mu, Sigma, mixWeight);
  %model = mixModelCreate(condGaussCpdCreate(mu, Sigma), 'gauss', numel(mixWeight), mixWeight);
end
[~, logp] = mixGaussInferLatent(model, X);
%logp = mixModelLogprob(model, X);
end
