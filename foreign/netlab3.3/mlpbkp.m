function g = mlpbkp(net, x, z, deltas)
%MLPBKP	Backpropagate gradient of error function for 2-layer network.
%
%	Description
%	G = MLPBKP(NET, X, Z, DELTAS) takes a network data structure NET
%	together with a matrix X of input vectors, a matrix  Z of hidden unit
%	activations, and a matrix DELTAS of the  gradient of the error
%	function with respect to the values of the output units (i.e. the
%	summed inputs to the output units, before the activation function is
%	applied). The return value is the gradient G of the error function
%	with respect to the network weights. Each row of X corresponds to one
%	input vector.
%
%	This function is provided so that the common backpropagation
%	algorithm can be used by multi-layer perceptron network models to
%	compute gradients for mixture density networks as well as standard
%	error functions.
%
%	See also
%	MLP, MLPGRAD, MLPDERIV, MDNGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Evaluate second-layer gradients.
gw2 = z'*deltas;
gb2 = sum(deltas, 1);

% Now do the backpropagation.
delhid = deltas*net.w2';
delhid = delhid.*(1.0 - z.*z);

% Finally, evaluate the first-layer gradients.
gw1 = x'*delhid;
gb1 = sum(delhid, 1);

g = [gw1(:)', gb1, gw2(:)', gb2];
