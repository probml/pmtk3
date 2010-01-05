function w = mdnpak(net)
%MDNPAK	Combines weights and biases into one weights vector.
%
%	Description
%	W = MDNPAK(NET) takes a mixture density network data structure NET
%	and  combines the network weights into a single row vector W.
%
%	See also
%	MDN, MDNUNPAK, MDNFWD, MDNERR, MDNGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)
%	David J Evans (1998)

errstring = consist(net, 'mdn');
if ~errstring
  error(errstring);
end
w = mlppak(net.mlp);
