function [cov, covf] = gpcovar(net, x)
%GPCOVAR Calculate the covariance for a Gaussian Process.
%
%	Description
%
%	COV = GPCOVAR(NET, X) takes  a Gaussian Process data structure NET
%	together with a matrix X of input vectors, and computes the
%	covariance matrix COV.  The inverse of this matrix is used when
%	calculating the mean and variance of the predictions made by NET.
%
%	[COV, COVF] = GPCOVAR(NET, X) also generates the covariance matrix
%	due to the covariance function specified by NET.COVARFN as calculated
%	by GPCOVARF.
%
%	See also
%	GP, GPPAK, GPUNPAK, GPCOVARP, GPCOVARF, GPFWD, GPERR, GPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'gp', x);
if ~isempty(errstring);
  error(errstring);
end

ndata = size(x, 1);

% Compute prior covariance
if nargout >= 2
  [covp, covf] = gpcovarp(net, x, x);
else
  covp = gpcovarp(net, x, x);
end

% Add output noise variance
cov = covp + (net.min_noise + exp(net.noise))*eye(ndata);

