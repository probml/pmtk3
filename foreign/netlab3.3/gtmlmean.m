function means = gtmlmean(net, data)
%GTMLMEAN Mean responsibility for data in a GTM.
%
%	Description
%	 MEANS = GTMLMEAN(NET, DATA) takes a GTM structure NET, and computes
%	the means of the responsibility  distributions for each data point in
%	DATA.
%
%	See also
%	GTM, GTMPOST, GTMLMODE
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check for consistency
errstring = consist(net, 'gtm', data);
if ~isempty(errstring)
  error(errstring);
end

R = gtmpost(net, data);
means = R*net.X;
