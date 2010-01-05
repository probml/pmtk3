function [post, a] = gtmpost(net, data)
%GTMPOST Latent space responsibility for data in a GTM.
%
%	Description
%	 POST = GTMPOST(NET, DATA) takes a GTM structure NET, and computes
%	the  responsibility at each latent space sample point NET.X for each
%	data point in DATA.
%
%	[POST, A] = GTMPOST(NET, DATA) also returns the activations A of the
%	GMM NET.GMMNET as computed by GMMPOST.
%
%	See also
%	GTM, GTMEM, GTMLMEAN, GMLMODE, GMMPROB
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check for consistency
errstring = consist(net, 'gtm', data);
if ~isempty(errstring)
  error(errstring);
end

net.gmmnet.centres = rbffwd(net.rbfnet, net.X);

[post, a] = gmmpost(net.gmmnet, data);
