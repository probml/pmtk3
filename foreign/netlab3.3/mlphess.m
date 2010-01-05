function [h, hdata] = mlphess(net, x, t, hdata)
%MLPHESS Evaluate the Hessian matrix for a multi-layer perceptron network.
%
%	Description
%	H = MLPHESS(NET, X, T) takes an MLP network data structure NET, a
%	matrix X of input values, and a matrix T of target values and returns
%	the full Hessian matrix H corresponding to the second derivatives of
%	the negative log posterior distribution, evaluated for the current
%	weight and bias values as defined by NET.
%
%	[H, HDATA] = MLPHESS(NET, X, T) returns both the Hessian matrix H and
%	the contribution HDATA arising from the data dependent term in the
%	Hessian.
%
%	H = MLPHESS(NET, X, T, HDATA) takes a network data structure NET, a
%	matrix X of input values, and a matrix T of  target values, together
%	with the contribution HDATA arising from the data dependent term in
%	the Hessian, and returns the full Hessian matrix H corresponding to
%	the second derivatives of the negative log posterior distribution.
%	This version saves computation time if HDATA has already been
%	evaluated for the current weight and bias values.
%
%	See also
%	MLP, HESSCHEK, MLPHDOTV, EVIDENCE
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'mlp', x, t);
if ~isempty(errstring);
  error(errstring);
end

if nargin == 3
  % Data term in Hessian needs to be computed
  hdata = datahess(net, x, t);
end

[h, hdata] = hbayes(net, hdata);

% Sub-function to compute data part of Hessian
function hdata = datahess(net, x, t)

hdata = zeros(net.nwts, net.nwts);

for v = eye(net.nwts);
  hdata(find(v),:) = mlphdotv(net, x, t, v);
end

return
