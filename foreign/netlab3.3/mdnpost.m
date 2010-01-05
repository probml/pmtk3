function [post, a] = mdnpost(mixparams, t)
%MDNPOST Computes the posterior probability for each MDN mixture component.
%
%	Description
%	POST = MDNPOST(MIXPARAMS, T) computes the posterior probability
%	P(J|T) of each data vector in T under the Gaussian mixture model
%	represented by the corresponding entries in MIXPARAMS. Each row of T
%	represents a single vector.
%
%	[POST, A] = MDNPOST(MIXPARAMS, T) also computes the activations A
%	(i.e. the probability P(T|J) of the data conditioned on each
%	component density) for a Gaussian mixture model.
%
%	See also
%	MDNGRAD, MDNPROB
%

%	Copyright (c) Ian T Nabney (1996-2001)
%	David J Evans (1998)

[prob a] = mdnprob(mixparams, t);

s = sum(prob, 2);
% Set any zeros to one before dividing
s = s + (s==0);
post = prob./(s*ones(1, mixparams.ncentres));
