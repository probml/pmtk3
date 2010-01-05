function [covp, covf] = gpcovarp(net, x1, x2)
%GPCOVARP Calculate the prior covariance for a Gaussian Process.
%
%	Description
%
%	COVP = GPCOVARP(NET, X1, X2) takes  a Gaussian Process data structure
%	NET together with two matrices X1 and X2 of input vectors,  and
%	computes the matrix of the prior covariance.  This is the function
%	component of the covariance plus the exponential of the bias term.
%
%	[COVP, COVF] = GPCOVARP(NET, X1, X2) also returns the function
%	component of the covariance.
%
%	See also
%	GP, GPCOVAR, GPCOVARF, GPERR, GPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(net, 'gp', x1);
if ~isempty(errstring);
  error(errstring);
end

if size(x1, 2) ~= size(x2, 2)
  error('Number of variables in x1 and x2 must be the same');
end

covf = gpcovarf(net, x1, x2);
covp = covf + exp(net.bias);