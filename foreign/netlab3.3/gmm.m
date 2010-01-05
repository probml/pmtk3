function mix = gmm(dim, ncentres, covar_type, ppca_dim)
%GMM	Creates a Gaussian mixture model with specified architecture.
%
%	Description
%	 MIX = GMM(DIM, NCENTRES, COVARTYPE) takes the dimension of the space
%	DIM, the number of centres in the mixture model and the type of the
%	mixture model, and returns a data structure MIX. The mixture model
%	type defines the covariance structure of each component  Gaussian:
%	  'spherical' = single variance parameter for each component: stored as a vector
%	  'diag' = diagonal matrix for each component: stored as rows of a matrix
%	  'full' = full matrix for each component: stored as 3d array
%	  'ppca' = probabilistic PCA: stored as principal components (in a 3d array
%	    and associated variances and off-subspace noise
%	 MIX = GMM(DIM, NCENTRES, COVARTYPE, PPCA_DIM) also sets the
%	dimension of the PPCA sub-spaces: the default value is one.
%
%	The priors are initialised to equal values summing to one, and the
%	covariances are all the identity matrix (or equivalent).  The centres
%	are initialised randomly from a zero mean unit variance Gaussian.
%	This makes use of the MATLAB function RANDN and so the seed for the
%	random weight initialisation can be set using RANDN('STATE', S) where
%	S is the state value.
%
%	The fields in MIX are
%	  
%	  type = 'gmm'
%	  nin = the dimension of the space
%	  ncentres = number of mixture components
%	  covartype = string for type of variance model
%	  priors = mixing coefficients
%	  centres = means of Gaussians: stored as rows of a matrix
%	  covars = covariances of Gaussians
%	 The additional fields for mixtures of PPCA are
%	  U = principal component subspaces
%	  lambda = in-space covariances: stored as rows of a matrix
%	 The off-subspace noise is stored in COVARS.
%
%	See also
%	GMMPAK, GMMUNPAK, GMMSAMP, GMMINIT, GMMEM, GMMACTIV, GMMPOST, 
%	GMMPROB
%

%	Copyright (c) Ian T Nabney (1996-2001)

if ncentres < 1
  error('Number of centres must be greater than zero')
end

mix.type = 'gmm';
mix.nin = dim;
mix.ncentres = ncentres;

vartypes = {'spherical', 'diag', 'full', 'ppca'};

if sum(strcmp(covar_type, vartypes)) == 0
  error('Undefined covariance type')
else
  mix.covar_type = covar_type;
end

% Make default dimension of PPCA subspaces one.
if strcmp(covar_type, 'ppca')
  if nargin < 4
    ppca_dim = 1;
  end
  if ppca_dim > dim
    error('Dimension of PPCA subspaces must be less than data.')
  end
  mix.ppca_dim = ppca_dim;
end

% Initialise priors to be equal and summing to one
mix.priors = ones(1,mix.ncentres) ./ mix.ncentres;

% Initialise centres
mix.centres = randn(mix.ncentres, mix.nin);

% Initialise all the variances to unity
switch mix.covar_type

case 'spherical'
  mix.covars = ones(1, mix.ncentres);
  mix.nwts = mix.ncentres + mix.ncentres*mix.nin + mix.ncentres;
case 'diag'
  % Store diagonals of covariance matrices as rows in a matrix
  mix.covars =  ones(mix.ncentres, mix.nin);
  mix.nwts = mix.ncentres + mix.ncentres*mix.nin + ...
    mix.ncentres*mix.nin;
case 'full'
  % Store covariance matrices in a row vector of matrices
  mix.covars = repmat(eye(mix.nin), [1 1 mix.ncentres]);
  mix.nwts = mix.ncentres + mix.ncentres*mix.nin + ...
    mix.ncentres*mix.nin*mix.nin;
case 'ppca'
  % This is the off-subspace noise: make it smaller than
  % lambdas
  mix.covars = 0.1*ones(1, mix.ncentres);
  % Also set aside storage for principal components and
  % associated variances
  init_space = eye(mix.nin);
  init_space = init_space(:, 1:mix.ppca_dim);
  init_space(mix.ppca_dim+1:mix.nin, :) = ...
    ones(mix.nin - mix.ppca_dim, mix.ppca_dim);
  mix.U = repmat(init_space , [1 1 mix.ncentres]);
  mix.lambda = ones(mix.ncentres, mix.ppca_dim);
  % Take account of additional parameters
  mix.nwts = mix.ncentres + mix.ncentres*mix.nin + ...
    mix.ncentres + mix.ncentres*mix.ppca_dim + ...
    mix.ncentres*mix.nin*mix.ppca_dim;
otherwise
  error(['Unknown covariance type ', mix.covar_type]);               
end

