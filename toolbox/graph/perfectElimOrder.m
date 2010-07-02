function order = perfectElimOrder(g)
%% Compute the perfect elimination order of a chordal graph
% See checkChordal
%% 


% inputs: 1. g, the p x p symmetric adjacency matrix with
% respect to an original ordering v_1, ..., v_p
%  order=[a permutation vector of the v_i].
%      order is a sequence alpha(1)...alpha(p) which is an ordering of
%      the v_i such that the sequence v_alpha(1)...v_alpha(p) is a
%      perfect numbering if it exists] % A numbering alpha is perfect if
%      nbrs(alpha(i)) intersect {alpha(1)...alpha(i-1)} is complete.
% A graph is chordal iff it has a perfect numbering.
% The Maximum Cardinality Search algorithm will create such a
% perfect numbering if possible.
% See Golumbic, "Algorithmic Graph Theory and Perfect Graphs",
% Cambridge Univ. Press, 1985, p85. % or Castillo, Gutierrez and Hadi,
% "Expert systems and probabilistic network models", Springer 1997, p134.
%

g = setdiag(g, 1);
d = size(g, 1);
order = zeros(1, d);
order(1) = 1;
for i=2:d
    numbered = order(1:i-1);
    capU = setdiffPMTK(1:d, numbered); % unnumbered verticies
    score = zeros(1, length(capU));
    for j=1:length(capU)
        u = capU(j);
        score(j) = length(intersectPMTK(neighbors(g, u), numbered));
    end
    u = capU(argmax(score));
    order(i) = u;
end





test = false;
if test
    [ischordal, elim] = checkChordal(g);
    assert(isequal(elim, order));
end


end