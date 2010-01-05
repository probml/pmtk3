function net = gtm(dim_latent, nlatent, dim_data, ncentres, rbfunc, ...
   prior)
%GTM	Create a Generative Topographic Map.
%
%	Description
%
%	NET = GTM(DIMLATENT, NLATENT, DIMDATA, NCENTRES, RBFUNC), takes the
%	dimension of the latent space DIMLATENT, the number of data points
%	sampled in the latent space NLATENT, the dimension of the data space
%	DIMDATA, the number of centres in the RBF model NCENTRES, the
%	activation function for the RBF RBFUNC and returns a data structure
%	NET. The parameters in the RBF and GMM sub-models are set by calls to
%	the corresponding creation routines RBF and GMM.
%
%	The fields in NET are
%	  type = 'gtm'
%	  nin = dimension of data space
%	  dimlatent = dimension of latent space
%	  rbfnet = RBF network data structure
%	  gmmnet = GMM data structure
%	  X = sample of latent points
%
%	NET = GTM(DIMLATENT, NLATENT, DIMDATA, NCENTRES, RBFUNC, PRIOR),
%	sets a Gaussian zero mean prior on the parameters of the RBF model.
%	PRIOR must be a scalar and represents the inverse variance of the
%	prior distribution.  This gives rise to a weight decay term in the
%	error function.
%
%	See also
%	GTMFWD, GTMPOST, RBF, GMM
%

%	Copyright (c) Ian T Nabney (1996-2001)

net.type = 'gtm';
% Input to functions is data
net.nin = dim_data;
net.dim_latent = dim_latent;

% Default is no regularisation
if nargin == 5
   prior = 0.0;
end

% Only allow scalar prior
if isstruct(prior) | size(prior) ~= [1 1]
   error('Prior must be a scalar');
end

% Create RBF network
net.rbfnet = rbf(dim_latent, ncentres, dim_data, rbfunc, ...
   'linear', prior);

% Mask all but output weights
net.rbfnet.mask = rbfprior(rbfunc, dim_latent, ncentres, dim_data);

% Create field for GMM output model
net.gmmnet = gmm(dim_data, nlatent, 'spherical');

% Create empty latent data sample
net.X = [];