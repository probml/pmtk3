function net = netunpak(net, w)
%NETUNPAK Separates weights vector into weight and bias matrices. 
%
%	Description
%	NET = NETUNPAK(NET, W) takes an net network data structure NET and  a
%	weight vector W, and returns a network data structure identical to
%	the input network, except that the componenet weight matrices have
%	all been set to the corresponding elements of W.  If there is  a MASK
%	field in the NET data structure, then the weights in W are placed in
%	locations corresponding to non-zero entries in the mask (so W should
%	have the same length as the number of non-zero entries in the MASK).
%
%	See also
%	NETPAK, NETFWD, NETERR, NETGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

unpakstr = [net.type, 'unpak'];

% Check if we are being passed a masked set of weights
if (isfield(net, 'mask'))
   if length(w) ~= size(find(net.mask), 1)
      error('Weight vector length does not match mask length')
   end
   % Do a full pack of all current network weights
   pakstr = [net.type, 'pak'];
   fullw = feval(pakstr, net);
   % Replace current weights with new ones
   fullw(logical(net.mask)) = w;
   w = fullw;
end

net = feval(unpakstr, net, w);