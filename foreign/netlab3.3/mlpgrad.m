function [g, gdata, gprior] = mlpgrad(net, x, t)
%MLPGRAD Evaluate gradient of error function for 2-layer network.
%
%	Description
%	G = MLPGRAD(NET, X, T) takes a network data structure NET  together
%	with a matrix X of input vectors and a matrix T of target vectors,
%	and evaluates the gradient G of the error function with respect to
%	the network weights. The error funcion corresponds to the choice of
%	output unit activation function. Each row of X corresponds to one
%	input vector and each row of T corresponds to one target vector.
%
%	[G, GDATA, GPRIOR] = MLPGRAD(NET, X, T) also returns separately  the
%	data and prior contributions to the gradient. In the case of multiple
%	groups in the prior, GPRIOR is a matrix with a row for each group and
%	a column for each weight parameter.
%
%	See also
%	MLP, MLPPAK, MLPUNPAK, MLPFWD, MLPERR, MLPBKP
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'mlp', x, t);
if ~isempty(errstring);
  error(errstring);
end
[y, z] = mlpfwd(net, x);
delout = y - t;

gdata = mlpbkp(net, x, z, delout);

[g, gdata, gprior] = gbayes(net, gdata);
