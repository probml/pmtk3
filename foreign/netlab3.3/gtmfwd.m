function mix = gtmfwd(net)
%GTMFWD	Forward propagation through GTM.
%
%	Description
%	 MIX = GTMFWD(NET) takes a GTM structure NET, and forward propagates
%	the latent data sample NET.X through the GTM to generate the
%	structure MIX which represents the Gaussian mixture model in data
%	space.
%
%	See also
%	GTM
%

%	Copyright (c) Ian T Nabney (1996-2001)

net.gmmnet.centres = rbffwd(net.rbfnet, net.X);
mix = net.gmmnet;
