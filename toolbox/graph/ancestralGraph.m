function [Ga, remaining] = ancestralGraph(G, V)
%% Construct the ancestral graph for the variables V in the dag G
% See http://courses.csail.mit.edu/6.867/lectures/lecture17_notes.pdf
%
%%
A = arrayfun(@(v)ancestors(G, v), V, 'UniformOutput', false);
remaining = uniquePMTK([A{:}, V]);
remove = setdiffPMTK(1:size(G, 1), remaining);
Ga = G;
Ga(remove, :) = [];
Ga(:, remove) = [];


end