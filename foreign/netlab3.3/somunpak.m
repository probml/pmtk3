function net = somunpak(net, w)
%SOMUNPAK Replaces node weights in SOM.
%
%	Description
%	NET = SOMUNPAK(NET, W) takes a SOM data structure NET and weight
%	matrix W (each node represented by a row) and puts the nodes back
%	into the multi-dimensional array NET.MAP.
%
%	The ordering of the parameters in W is defined by the indexing of the
%	multi-dimensional array NET.MAP.
%
%	See also
%	SOM, SOMPAK
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(net, 'som');
if ~isempty(errstring)
    error(errstring);
end
% Put weights back into network data structure
net.map = reshape(w', [net.nin net.map_size]);