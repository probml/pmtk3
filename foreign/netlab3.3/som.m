function net = som(nin, map_size)
%SOM	Creates a Self-Organising Map.
%
%	Description
%	NET = SOM(NIN, MAP_SIZE) creates a SOM NET with input dimension (i.e.
%	data dimension) NIN and map dimensions MAP_SIZE.  Only two-
%	dimensional maps are currently implemented.
%
%	The fields in NET are
%	  type = 'som'
%	  nin = number of inputs
%	  map_dim = dimension of map (constrained to be 2)
%	  map_size = grid size: number of nodes in each dimension
%	  num_nodes = number of nodes: the product of values in map_size
%	  map = map_dim+1 dimensional array containing nodes
%	  inode_dist = map of inter-node distances using Manhatten metric
%
%	The map contains the node vectors arranged column-wise in the first
%	dimension of the array.
%
%	See also
%	KMEANS, SOMFWD, SOMTRAIN
%

%	Copyright (c) Ian T Nabney (1996-2001)

net.type = 'som';
net.nin = nin;

% Create Map of nodes
if round(map_size) ~= map_size | (map_size < 1)
    error('SOM specification must contain positive integers');
end

net.map_dim = length(map_size);
if net.map_dim ~= 2
    error('SOM is a 2 dimensional map');
end
net.num_nodes = prod(map_size);
% Centres are stored by column as first index of multi-dimensional array.
% This makes extracting them later more easy.
% Initialise with rand to create square grid
net.map = rand([nin, map_size]);
net.map_size = map_size;

% Crude function to compute inter-node distances
net.inode_dist = zeros([map_size, net.num_nodes]);
for m = 1:net.num_nodes
    node_loc = [1+fix((m-1)/map_size(2)), 1+rem((m-1),map_size(2))];
    for k = 1:map_size(1)
	for l = 1:map_size(2)
	    net.inode_dist(k, l, m) = round(max(abs([k l] - node_loc)));
	end
    end
end
