function w = mlppak(net)
%MLPPAK	Combines weights and biases into one weights vector.
%
%	Description
%	W = MLPPAK(NET) takes a network data structure NET and combines the
%	component weight matrices bias vectors into a single row vector W.
%	The facility to switch between these two representations for the
%	network parameters is useful, for example, in training a network by
%	error function minimization, since a single vector of parameters can
%	be handled by general-purpose optimization routines.
%
%	The ordering of the paramters in W is defined by
%	  w = [net.w1(:)', net.b1, net.w2(:)', net.b2];
%	 where W1 is the first-layer weight matrix, B1 is the first-layer
%	bias vector, W2 is the second-layer weight matrix, and B2 is the
%	second-layer bias vector.
%
%	See also
%	MLP, MLPUNPAK, MLPFWD, MLPERR, MLPBKP, MLPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'mlp');
if ~isempty(errstring);
  error(errstring);
end

w = [net.w1(:)', net.b1, net.w2(:)', net.b2];

