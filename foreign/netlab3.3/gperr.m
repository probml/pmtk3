function [e, edata, eprior] = gperr(net, x, t)
%GPERR	Evaluate error function for Gaussian Process.
%
%	Description
%	E = GPERR(NET, X, T) takes a Gaussian Process data structure NET
%	together  with a matrix X of input vectors and a matrix T of target
%	vectors, and evaluates the error function E. Each row of X
%	corresponds to one input vector and each row of T corresponds to one
%	target vector.
%
%	[E, EDATA, EPRIOR] = GPERR(NET, X, T) additionally returns the data
%	and hyperprior components of the error, assuming a Gaussian prior on
%	the weights with mean and variance parameters PRMEAN and PRVARIANCE
%	taken from the network data structure NET.
%
%	See also
%	GP, GPCOVAR, GPFWD, GPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(net, 'gp', x, t);
if ~isempty(errstring);
  error(errstring);
end

cn = gpcovar(net, x);

edata = 0.5*(sum(log(eig(cn, 'nobalance'))) + t'*inv(cn)*t);

% Evaluate the hyperprior contribution to the error.
% The hyperprior is Gaussian with mean pr_mean and variance
% pr_variance
if isfield(net, 'pr_mean')
  w = gppak(net);
  m = repmat(net.pr_mean, size(w));
  if size(net.pr_mean) == [1 1]
    eprior = 0.5*((w-m)*(w-m)');
    e2 = eprior/net.pr_var;
  else
    wpr = repmat(w, size(net.pr_mean, 1), 1)';
    eprior = 0.5*(((wpr - m').^2).*net.index);
    e2 = (sum(eprior, 1))*(1./net.pr_var);
  end
else
  e2 = 0;
  eprior = 0;
end

e = edata + e2;

