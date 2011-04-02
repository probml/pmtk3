function [X, y] = mixGaussSample(varargin)
% Sample n samples from a mixture of multivariate gaussians
% all with the same dimensionality. 
% [X,z] = mixGaussSample(model, N)
% or
% [X,z] = mixGaussSample(mu, Sigma, mixWeight, N)
% where
% mu(:,c)       -  a d-by-C matrix, with mu(:, c) = the mean of component c.
% Sigma(:,:,c)
% mixweight(c)
%
%
% nsamples   - the number of samples to generate
% X          - an nsamples-by-d matrix 
% y          - an nsamples-by-1 vector, the component labels in 1:C

% This file is from pmtk3.googlecode.com


%m = mixModelCreate(condGaussCpdCreate(mu, Sigma), 'gauss', numel(mixWeight), mixWeight);
%[X, y] = mixModelSample(m, nsamples); 

if nargin == 2
  model = varargin{1};
  nsamples = varargin{2};
else
  mu = varargin{1}; Sigma = varargin{2}; mixWeight = varargin{3}; nsamples = varargin{4};
  model = mixGaussCreate(mu, Sigma, mixWeight);
  %model = mixModelCreate(condGaussCpdCreate(mu, Sigma), 'gauss', numel(mixWeight), mixWeight);
end

y = sampleDiscrete(model.mixWeight, nsamples, 1);

mu    = model.cpd.mu;
Sigma = model.cpd.Sigma;
d     = size(Sigma, 1);
X     = zeros(nsamples, d);
for j = 1:nsamples
  X(j, :) = gaussSample(mu(:, y(j)), Sigma(:, :, y(j)), 1);
end

        
end
