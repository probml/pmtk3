function [data, c, prior, sd] = dem2ddat(ndata)
%DEM2DDAT Generates two dimensional data for demos.
%
%	Description
%	The data is drawn from three spherical Gaussian distributions with
%	priors 0.3, 0.5 and 0.2; centres (2, 3.5), (0, 0) and (0,2); and
%	standard deviations 0.2, 0.5 and 1.0.  DATA = DEM2DDAT(NDATA)
%	generates NDATA points.
%
%	[DATA, C] = DEM2DDAT(NDATA) also returns a matrix containing the
%	centres of the Gaussian distributions.
%
%	See also
%	DEMGMM1, DEMKMEAN, DEMKNN1
%

%	Copyright (c) Ian T Nabney (1996-2001)

input_dim = 2;

% Fix seed for reproducible results
randn('state', 42);

% Generate mixture of three Gaussians in two dimensional space
data = randn(ndata, input_dim);

% Priors for the three clusters
prior(1) = 0.3;
prior(2) = 0.5;
prior(3) = 0.2;

% Cluster centres
c = [2.0, 3.5; 0.0, 0.0; 0.0, 2.0];

% Cluster standard deviations
sd  = [0.2 0.5 1.0];

% Put first cluster at (2, 3.5)
data(1:prior(1)*ndata, 1) = data(1:prior(1)*ndata, 1) * 0.2 + c(1,1);
data(1:prior(1)*ndata, 2) = data(1:prior(1)*ndata, 2) * 0.2 + c(1,2);

% Leave second cluster at (0,0)
data((prior(1)*ndata + 1):(prior(2)+prior(1))*ndata, :) = ...
	data((prior(1)*ndata + 1):(prior(2)+prior(1))*ndata, :) * 0.5;

% Put third cluster at (0,2)
data((prior(1)+prior(2))*ndata +1:ndata, 2) = ...
	data((prior(1)+prior(2))*ndata+1:ndata, 2) + c(3, 2);
