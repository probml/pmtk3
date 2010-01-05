function prob = gmmprob(mix, x)
%GMMPROB Computes the data probability for a Gaussian mixture model.
%
%	Description
%	 This function computes the unconditional data density P(X) for a
%	Gaussian mixture model.  The data structure MIX defines the mixture
%	model, while the matrix X contains the data vectors.  Each row of X
%	represents a single vector.
%
%	See also
%	GMM, GMMPOST, GMMACTIV
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check that inputs are consistent
errstring = consist(mix, 'gmm', x);
if ~isempty(errstring)
  error(errstring);
end

% Compute activations
a = gmmactiv(mix, x);

% Form dot product with priors
prob = a * (mix.priors)';