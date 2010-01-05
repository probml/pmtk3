function net = glmunpak(net, w)
%GLMUNPAK Separates weights vector into weight and bias matrices. 
%
%	Description
%	NET = GLMUNPAK(NET, W) takes a glm network data structure NET and  a
%	weight vector W, and returns a network data structure identical to
%	the input network, except that the first-layer weight matrix W1 and
%	the first-layer bias vector B1 have been set to the corresponding
%	elements of W.
%
%	See also
%	GLM, GLMPAK, GLMFWD, GLMERR, GLMGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'glm');
if ~errstring
  error(errstring);
end

if net.nwts ~= length(w)
  error('Invalid weight vector length')
end

nin = net.nin;
nout = net.nout;
net.w1 = reshape(w(1:nin*nout), nin, nout);
net.b1 = reshape(w(nin*nout + 1: (nin + 1)*nout), 1, nout);
