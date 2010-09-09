function [Rhat, converged] = epsrMultidim(samples)
% EPSR "estimated potential scale reduction" statistic for vectors
%
% Inputs
% samples(i,j,c) for sample i, dimension j, chain c
%
% Outputs
% Rhat(j) = epsr stat for component j
% converged = true iff all Rhat < 1.1

% This file is from pmtk3.googlecode.com


[nsamples ndims nchains] = size(samples); %#ok
Rhat = zeros(1,ndims);
for j=1:ndims
  Rhat(j) = epsr(squeeze(samples(:,j,:)));
end
converged = all(Rhat <= 1.1);
