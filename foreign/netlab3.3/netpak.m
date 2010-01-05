function w = netpak(net)
%NETPAK	Combines weights and biases into one weights vector.
%
%	Description
%	W = NETPAK(NET) takes a network data structure NET and combines the
%	component weight matrices  into a single row vector W. The facility
%	to switch between these two representations for the network
%	parameters is useful, for example, in training a network by error
%	function minimization, since a single vector of parameters can be
%	handled by general-purpose optimization routines.  This function also
%	takes into account a MASK defined as a field in NET by removing any
%	weights that correspond to entries of 0 in the mask.
%
%	See also
%	NET, NETUNPAK, NETFWD, NETERR, NETGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

pakstr = [net.type, 'pak'];
w = feval(pakstr, net);
% Return masked subset of weights
if (isfield(net, 'mask'))
   w = w(logical(net.mask));
end