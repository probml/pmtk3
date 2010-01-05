function w = rbfpak(net)
%RBFPAK	Combines all the parameters in an RBF network into one weights vector.
%
%	Description
%	W = RBFPAK(NET) takes a network data structure NET and combines the
%	component parameter matrices into a single row vector W.
%
%	See also
%	RBFUNPAK, RBF
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(net, 'rbf');
if ~errstring
  error(errstring);
end

w = [net.c(:)', net.wi, net.w2(:)', net.b2];
