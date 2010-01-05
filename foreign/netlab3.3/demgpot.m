function g = demgpot(x, mix)
%DEMGPOT Computes the gradient of the negative log likelihood for a mixture model.
%
%	Description
%	This function computes the gradient of the negative log of the
%	unconditional data density P(X) with respect to the coefficients of
%	the data vector X for a Gaussian mixture model.  The data structure
%	MIX defines the mixture model, while the matrix X contains the data
%	vector as a row vector. Note the unusual order of the arguments: this
%	is so that the function can be used in DEMHMC1 directly for sampling
%	from the distribution P(X).
%
%	See also
%	DEMHMC1, DEMMET1, DEMPOT
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Computes the potential gradient

temp = (ones(mix.ncentres,1)*x)-mix.centres;
temp = temp.*(gmmactiv(mix,x)'*ones(1, mix.nin));
% Assume spherical covariance structure
if ~strcmp(mix.covar_type, 'spherical')
  error('Spherical covariance only.')
end
temp = temp./(mix.covars'*ones(1, mix.nin));
temp = temp.*(mix.priors'*ones(1, mix.nin));
g = sum(temp, 1)/gmmprob(mix, x);