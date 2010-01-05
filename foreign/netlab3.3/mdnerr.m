function e = mdnerr(net, x, t)
%MDNERR	Evaluate error function for Mixture Density Network.
%
%	Description
%	 E = MDNERR(NET, X, T) takes a mixture density network data structure
%	NET, a matrix X of input vectors and a matrix T of target vectors,
%	and evaluates the error function E. The error function is the
%	negative log likelihood of the target data under the conditional
%	density given by the mixture model parameterised by the MLP.  Each
%	row of X corresponds to one input vector and each row of T
%	corresponds to one target vector.
%
%	See also
%	MDN, MDNFWD, MDNGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)
%	David J Evans (1998)

% Check arguments for consistency
errstring = consist(net, 'mdn', x, t);
if ~isempty(errstring)
  error(errstring);
end

% Get the output mixture models
mixparams = mdnfwd(net, x);

% Compute the probabilities of mixtures
probs     = mdnprob(mixparams, t);
% Compute the error
e       = sum( -log(max(eps, sum(probs, 2))));

