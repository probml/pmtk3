function [c] = sompak(net)
%SOMPAK	Combines node weights into one weights matrix.
%
%	Description
%	C = SOMPAK(NET) takes a SOM data structure NET and combines the node
%	weights into a matrix of centres C where each row represents the node
%	vector.
%
%	The ordering of the parameters in W is defined by the indexing of the
%	multi-dimensional array NET.MAP.
%
%	See also
%	SOM, SOMUNPAK
%

%	Copyright (c) Ian T Nabney (1996-2001)

errstring = consist(net, 'som');
if ~isempty(errstring)
    error(errstring);
end
% Returns map as a sequence of row vectors
c = (reshape(net.map, net.nin, net.num_nodes))';
