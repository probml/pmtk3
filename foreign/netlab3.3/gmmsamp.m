function [data, label] = gmmsamp(mix, n)
%GMMSAMP Sample from a Gaussian mixture distribution.
%
%	Description
%
%	DATA = GSAMP(MIX, N) generates a sample of size N from a Gaussian
%	mixture distribution defined by the MIX data structure. The matrix X
%	has N rows in which each row represents a MIX.NIN-dimensional sample
%	vector.
%
%	[DATA, LABEL] = GMMSAMP(MIX, N) also returns a column vector of
%	classes (as an index 1..N) LABEL.
%
%	See also
%	GSAMP, GMM
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check input arguments
errstring = consist(mix, 'gmm');
if ~isempty(errstring)
  error(errstring);
end
if n < 1
  error('Number of data points must be positive')
end

% Determine number to sample from each component
priors = rand(1, n);

% Pre-allocate data array
data = zeros(n, mix.nin);
if nargout > 1
  label = zeros(n, 1);
end
cum_prior = 0;		% Cumulative sum of priors
total_samples = 0;	% Cumulative sum of number of sampled points
for j = 1:mix.ncentres
  num_samples = sum(priors >= cum_prior & ...
    priors < cum_prior + mix.priors(j));
  % Form a full covariance matrix
  switch mix.covar_type
    case 'spherical'
      covar = mix.covars(j) * eye(mix.nin);
    case 'diag'
      covar = diag(mix.covars(j, :));
    case 'full'
      covar = mix.covars(:, :, j);
    case 'ppca'
      covar = mix.covars(j) * eye(mix.nin) + ...
        mix.U(:, :, j)* ...
        (diag(mix.lambda(j, :))-(mix.covars(j)*eye(mix.ppca_dim)))* ...
        (mix.U(:, :, j)');
    otherwise
      error(['Unknown covariance type ', mix.covar_type]);
  end
  data(total_samples+1:total_samples+num_samples, :) = ...
    gsamp(mix.centres(j, :), covar, num_samples);
  if nargout > 1
    label(total_samples+1:total_samples+num_samples) = j;
  end
  cum_prior = cum_prior + mix.priors(j);
  total_samples = total_samples + num_samples;
end
  
