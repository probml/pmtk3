function net = mdnunpak(net, w)
%MDNUNPAK Separates weights vector into weight and bias matrices. 
%
%	Description
%	NET = MDNUNPAK(NET, W) takes an mdn network data structure NET and  a
%	weight vector W, and returns a network data structure identical to
%	the input network, except that the weights in the MLP sub-structure
%	are set to the corresponding elements of W.
%
%	See also
%	MDN, MDNPAK, MDNFWD, MDNERR, MDNGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)
%	David J Evans (1998)

errstring = consist(net, 'mdn');
if ~errstring
  error(errstring);
end
if net.nwts ~= length(w)
  error('Invalid weight vector length')
end

net.mlp = mlpunpak(net.mlp, w);
