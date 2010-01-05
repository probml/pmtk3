function net = gpinit(net, tr_in, tr_targets, prior)
%GPINIT	Initialise Gaussian Process model.
%
%	Description
%	NET = GPINIT(NET, TRIN, TRTARGETS) takes a Gaussian Process data
%	structure NET  together  with a matrix TRIN of training input vectors
%	and a matrix TRTARGETS of  training target vectors, and stores them
%	in NET. These datasets are required if the corresponding inverse
%	covariance matrix is not supplied to GPFWD. This is important if the
%	data structure is saved and then reloaded before calling GPFWD. Each
%	row of TRIN corresponds to one input vector and each row of TRTARGETS
%	corresponds to one target vector.
%
%	NET = GPINIT(NET, TRIN, TRTARGETS, PRIOR) additionally initialises
%	the parameters in NET from the PRIOR data structure which contains
%	the mean and variance of the Gaussian distribution which is sampled
%	from.
%
%	See also
%	GP, GPFWD
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(net, 'gp', tr_in, tr_targets);
if ~isempty(errstring);
  error(errstring);
end

if nargin >= 4 
  % Initialise weights at random
  if size(prior.pr_mean) == [1 1]
    w = randn(1, net.nwts).*sqrt(prior.pr_var) + ...
       repmat(prior.pr_mean, 1, net.nwts);
  else
    sig = sqrt(prior.index*prior.pr_var);
    w = sig'.*randn(1, net.nwts) + (prior.index*prior.pr_mean)'; 
  end
  net = gpunpak(net, w);
end

net.tr_in = tr_in;
net.tr_targets = tr_targets;
