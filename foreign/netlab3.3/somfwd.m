function [d2, win_nodes] = somfwd(net, x)
%SOMFWD	Forward propagation through a Self-Organising Map.
%
%	Description
%	D2 = SOMFWD(NET, X) propagates the data matrix X through  a SOM NET,
%	returning the squared distance matrix D2 with dimension NIN by
%	NUM_NODES.  The $i$th row represents the squared Euclidean distance
%	to each of the nodes of the SOM.
%
%	[D2, WIN_NODES] = SOMFWD(NET, X) also returns the indices of the
%	winning nodes for each pattern.
%
%	See also
%	SOM, SOMTRAIN
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check for consistency
errstring = consist(net, 'som', x);
if ~isempty(errstring)
    error(errstring);
end

% Turn nodes into matrix of centres
nodes = (reshape(net.map, net.nin, net.num_nodes))';
% Compute squared distance matrix
d2 = dist2(x, nodes);
% Find winning node for each pattern: minimum value in each row
[w, win_nodes] = min(d2, [], 2);
