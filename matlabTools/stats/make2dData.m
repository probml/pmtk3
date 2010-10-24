function [data, labels] = make2dData(ndata, Nclasses)

% Generate mixture of 2-3 Gaussians in two dimensional space
% Based on dem2data from netlab

% This file is from pmtk3.googlecode.com


data = randn(ndata, 2);

% Cluster centres
c = [2.0, 3.5; 0.0, 0.0; 0.0, 2.0];

% Cluster standard deviations
sd  = 1*[1 1 1];

if Nclasses == 2
  prior = [0.5 0.5];
else
  prior = [0.3 0.3 0.4];
end

ndx = partitionData(1:ndata, prior);
for i=1:Nclasses
  labels(ndx{i}) = i;
  % shift and scale data for each class
  data(ndx{i}, 1) = data(ndx{i}, 1) * sd(i) + c(i,1);
  data(ndx{i}, 2) = data(ndx{i}, 2) * sd(i) + c(i,2);
end
