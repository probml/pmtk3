function prob = gtmprob(net, data)
%GTMPROB Probability for data under a GTM.
%
%	Description
%	 PROB = GTMPROB(NET, DATA) takes a GTM structure NET, and computes
%	the probability of each point in the dataset DATA.
%
%	See also
%	GTM, GTMEM, GTMLMEAN, GTMLMODE, GTMPOST
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check for consistency
errstring = consist(net, 'gtm', data);
if ~isempty(errstring)
  error(errstring);
end

net.gmmnet.centres = rbffwd(net.rbfnet, net.X);

prob = gmmprob(net.gmmnet, data);
