function [y, sigsq] = gpfwd(net, x, cninv)
%GPFWD	Forward propagation through Gaussian Process.
%
%	Description
%	Y = GPFWD(NET, X) takes a Gaussian Process data structure NET
%	together  with a matrix X of input vectors, and forward propagates
%	the inputs through the model to generate a matrix Y of output
%	vectors.  Each row of X corresponds to one input vector and each row
%	of Y corresponds to one output vector.  This assumes that the
%	training data (both inputs and targets) has been stored in NET by a
%	call to GPINIT; these are needed to compute the training data
%	covariance matrix.
%
%	[Y, SIGSQ] = GPFWD(NET, X) also generates a column vector SIGSQ of
%	conditional variances (or squared error bars) where each value
%	corresponds to a pattern.
%
%	[Y, SIGSQ] = GPFWD(NET, X, CNINV) uses the pre-computed inverse
%	covariance matrix CNINV in the forward propagation.  This increases
%	efficiency if several calls to GPFWD are made.
%
%	See also
%	GP, DEMGP, GPINIT
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(net, 'gp', x);
if ~isempty(errstring);
  error(errstring);
end

if ~(isfield(net, 'tr_in') & isfield(net, 'tr_targets'))
   error('Require training inputs and targets');
end

if nargin == 2
  % Inverse covariance matrix not supplied.
  cninv = inv(gpcovar(net, net.tr_in));
end
ktest = gpcovarp(net, x, net.tr_in);

% Predict mean
y = ktest*cninv*net.tr_targets;

if nargout >= 2
  % Predict error bar
  ndata = size(x, 1);
  sigsq = (ones(ndata, 1) * gpcovarp(net, x(1,:), x(1,:))) ...
    - sum((ktest*cninv).*ktest, 2); 
end
