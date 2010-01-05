function [post, a] = gmmpost(mix, x)
%GMMPOST Computes the class posterior probabilities of a Gaussian mixture model.
%
%	Description
%	This function computes the posteriors POST (i.e. the probability of
%	each component conditioned on the data P(J|X)) for a Gaussian mixture
%	model.   The data structure MIX defines the mixture model, while the
%	matrix X contains the data vectors.  Each row of X represents a
%	single vector.
%
%	See also
%	GMM, GMMACTIV, GMMPROB
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check that inputs are consistent
errstring = consist(mix, 'gmm', x);
if ~isempty(errstring)
  error(errstring);
end

ndata = size(x, 1);

a = gmmactiv(mix, x);

post = (ones(ndata, 1)*mix.priors).*a;
s = sum(post, 2);
if any(s==0)
   warning('Some zero posterior probabilities')
   % Set any zeros to one before dividing
   zero_rows = find(s==0);
   s = s + (s==0);
   post(zero_rows, :) = 1/mix.ncentres;
end
post = post./(s*ones(1, mix.ncentres));
