function [X, y] = mixGaussSample(model, nsamples)
% Sample n samples from a mixture of multivariate gaussians all with the 
% same dimensionality.
%
% model is a struct with the fields mu, Sigma, and mixweight.  
% mu(:,c)       -  a d-by-C matrix, with mu(:, c) = the mean of component c.
% Sigma(:,:,c)
% mixweight(c)
%
%
% nsamples   - the number of samples to generate
% X          - an nsamples-by-d matrix 
% y          - an nsamples-by-1 vector, the component labels in 1:C

mus = model.mu; Sigmas = model.Sigma; mix = model.mixweight; 

d = size(mus, 1);
y = sampleDiscrete(mix, nsamples, 1);
X = zeros(nsamples, d);
for j=1:nsamples
  modelj = struct('mu', mus(:, y(j)), 'Sigma', Sigmas(:, :, y(j)));
  X(j, :) = gaussSample(modelj) ;
end

