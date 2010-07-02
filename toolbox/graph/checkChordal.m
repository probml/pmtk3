function [chordal, order]=checkChordal(g)
% inputs: 1. g, the p x p symmetric adjacency matrix with
% respect to an original ordering v_1, ..., v_p

% output: 1. chordal=1/0 (yes/no)
% 2. order=[a permutation vector of the v_i].
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
%PMTKauthor Kevin Murphy
%PMTKmodified Helen Armstrong

g=setdiag(g, 1);
p = size(g,1);
order = zeros(1,p);
chordal = true;
numbered = [1];
order(1) = 1;
for i=2:p
    capU = setdiff(1:p, numbered); % unnumbered verticies
    score = zeros(1, length(capU));
    for u_i=1:length(capU)
        u = capU(u_i);
        score(u_i) = length(intersect(neighbors(g, u), numbered));
    end
    u = capU(argmax(score));
    numbered = [numbered u];
    order(i) = u;
    pa = intersect(neighbors(g,u), order(1:i-1));
    % already numbered neighbours
    if ~isequal(g(pa,pa), ones(length(pa)))
        chordal = false; break;
    end
end