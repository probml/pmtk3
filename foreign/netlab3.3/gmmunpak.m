function mix = gmmunpak(mix, p)
%GMMUNPAK Separates a vector of Gaussian mixture model parameters into its components.
%
%	Description
%	MIX = GMMUNPAK(MIX, P) takes a GMM data structure MIX and  a single
%	row vector of parameters P and returns a mixture data structure
%	identical to the input MIX, except that the mixing coefficients
%	PRIORS, centres CENTRES and covariances COVARS  (and, for PPCA, the
%	lambdas and U (PCA sub-spaces)) are all set to the corresponding
%	elements of P.
%
%	See also
%	GMM, GMMPAK
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(mix, 'gmm');
if ~errstring
  error(errstring);
end
if mix.nwts ~= length(p)
  error('Invalid weight vector length')
end

mark1 = mix.ncentres;
mark2 = mark1 + mix.ncentres*mix.nin;

mix.priors = reshape(p(1:mark1), 1, mix.ncentres);
mix.centres = reshape(p(mark1 + 1:mark2), mix.ncentres, mix.nin);
switch mix.covar_type
  case 'spherical'
    mark3 = mix.ncentres*(2 + mix.nin);
    mix.covars = reshape(p(mark2 + 1:mark3), 1, mix.ncentres);
  case 'diag'
    mark3 = mix.ncentres*(1 + mix.nin + mix.nin);
    mix.covars = reshape(p(mark2 + 1:mark3), mix.ncentres, mix.nin);
  case 'full'
    mark3 = mix.ncentres*(1 + mix.nin + mix.nin*mix.nin);
    mix.covars = reshape(p(mark2 + 1:mark3), mix.nin, mix.nin, ...
      mix.ncentres);
  case 'ppca'
    mark3 = mix.ncentres*(2 + mix.nin);
    mix.covars = reshape(p(mark2 + 1:mark3), 1, mix.ncentres);
    % Now also extract k and eigenspaces
    mark4 = mark3 + mix.ncentres*mix.ppca_dim;
    mix.lambda = reshape(p(mark3 + 1:mark4), mix.ncentres, ...
      mix.ppca_dim);
    mix.U = reshape(p(mark4 + 1:end), mix.nin, mix.ppca_dim, ...
      mix.ncentres);
  otherwise
    error(['Unknown covariance type ', mix.covar_type]);
end
  
