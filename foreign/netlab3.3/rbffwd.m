function [a, z, n2] = rbffwd(net, x)
%RBFFWD	Forward propagation through RBF network with linear outputs.
%
%	Description
%	A = RBFFWD(NET, X) takes a network data structure NET and a matrix X
%	of input vectors and forward propagates the inputs through the
%	network to generate a matrix A of output vectors. Each row of X
%	corresponds to one input vector and each row of A contains the
%	corresponding output vector. The activation function that is used is
%	determined by NET.ACTFN.
%
%	[A, Z, N2] = RBFFWD(NET, X) also generates a matrix Z of the hidden
%	unit activations where each row corresponds to one pattern. These
%	hidden unit activations represent the design matrix for the RBF.  The
%	matrix N2 is the squared distances between each basis function centre
%	and each pattern in which each row corresponds to a data point.
%
%	See also
%	RBF, RBFERR, RBFGRAD, RBFPAK, RBFTRAIN, RBFUNPAK
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'rbf', x);
if ~isempty(errstring);
  error(errstring);
end

[ndata, data_dim] = size(x);

% Calculate squared norm matrix, of dimension (ndata, ncentres)
n2 = dist2(x, net.c);

% Switch on activation function type
switch net.actfn

  case 'gaussian'	% Gaussian
    % Calculate width factors: net.wi contains squared widths
    wi2 = ones(ndata, 1) * (2 .* net.wi);

    % Now compute the activations
    z = exp(-(n2./wi2));

  case 'tps'		% Thin plate spline
    z = n2.*log(n2+(n2==0));

  case 'r4logr'		% r^4 log r
    z = n2.*n2.*log(n2+(n2==0));

  otherwise
    error('Unknown activation function in rbffwd')
end

a = z*net.w2 + ones(ndata, 1)*net.b2;