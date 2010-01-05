function net = mlpunpak(net, w)
%MLPUNPAK Separates weights vector into weight and bias matrices. 
%
%	Description
%	NET = MLPUNPAK(NET, W) takes an mlp network data structure NET and  a
%	weight vector W, and returns a network data structure identical to
%	the input network, except that the first-layer weight matrix W1, the
%	first-layer bias vector B1, the second-layer weight matrix W2 and the
%	second-layer bias vector B2 have all been set to the corresponding
%	elements of W.
%
%	See also
%	MLP, MLPPAK, MLPFWD, MLPERR, MLPBKP, MLPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'mlp');
if ~isempty(errstring);
  error(errstring);
end

if net.nwts ~= length(w)
  error('Invalid weight vector length')
end

nin = net.nin;
nhidden = net.nhidden;
nout = net.nout;

mark1 = nin*nhidden;
net.w1 = reshape(w(1:mark1), nin, nhidden);
mark2 = mark1 + nhidden;
net.b1 = reshape(w(mark1 + 1: mark2), 1, nhidden);
mark3 = mark2 + nhidden*nout;
net.w2 = reshape(w(mark2 + 1: mark3), nhidden, nout);
mark4 = mark3 + nout;
net.b2 = reshape(w(mark3 + 1: mark4), 1, nout);
