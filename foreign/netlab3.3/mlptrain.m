function [net, error] = mlptrain(net, x, t, its);
%MLPTRAIN Utility to train an MLP network for demtrain
%
%	Description
%
%	[NET, ERROR] = MLPTRAIN(NET, X, T, ITS) trains a network data
%	structure NET using the scaled conjugate gradient algorithm  for ITS
%	cycles with input data X, target data T.
%
%	See also
%	DEMTRAIN, SCG, NETOPT
%

%	Copyright (c) Ian T Nabney (1996-2001)

options = zeros(1,18);
options(1) = -1;	% To prevent any messages at all
options(9) = 0;
options(14) = its;

[net, options] = netopt(net, options, x, t, 'scg');

error = options(8);

