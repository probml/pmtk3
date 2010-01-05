function net = rbfunpak(net, w)
%RBFUNPAK Separates a vector of RBF weights into its components.
%
%	Description
%	NET = RBFUNPAK(NET, W) takes an RBF network data structure NET and  a
%	weight vector W, and returns a network data structure identical to
%	the input network, except that the centres C, the widths WI, the
%	second-layer weight matrix W2 and the second-layer bias vector B2
%	have all been set to the corresponding elements of W.
%
%	See also
%	RBFPAK, RBF
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'rbf');
if ~errstring
  error(errstring);
end

if net.nwts ~= length(w)
  error('Invalid length of weight vector')
end

nin 	= net.nin;
nhidden = net.nhidden;
nout 	= net.nout;

mark1 = nin*nhidden;
net.c = reshape(w(1:mark1), nhidden, nin);
if strcmp(net.actfn, 'gaussian')
  mark2 = mark1 + nhidden;
  net.wi = reshape(w(mark1+1:mark2), 1, nhidden);
else
  mark2 = mark1;
  net.wi = [];
end
mark3 = mark2 + nhidden*nout;
net.w2 = reshape(w(mark2+1:mark3), nhidden, nout);
mark4 = mark3 + nout;
net.b2 = reshape(w(mark3+1:mark4), 1, nout);