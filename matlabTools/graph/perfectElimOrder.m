function [order, chordal, cliques, numpa] = perfectElimOrder(G, initNode)
%% Compute the perfect elimination order of a chordal graph
% Uses the Maximum Cardinality Search algorithm
% chordal = false if graph is not chordal 
% Also returns maximal cliques of the graph, in an order
% that satisfies running intersection property
%
% See perfectElimDemo for an example

% This file is from pmtk3.googlecode.com


if nargin < 2, initNode = 1; end
G     = logical(G); 
G     = setdiag(G, true); % for chordality checking
d     = size(G, 1); 
order = zeros(1, d); 
numbered    = false(1, d); 
order(1)    = initNode; 
numbered(initNode) = true; 
chordal = true;
C = cell(1,d);
numpa = zeros(1,d);
for i=2:d
  % For each un-numbered node, find the one with the greatest
  % number of numbered neighbors and pick it as next in order
  score = zeros(1,d);
  U = find(~numbered);% unnumbered verticies
  N = find(numbered); 
  assert(isequal(N, order(1:i-1)))
  for u=U
     score(u) = length(intersectPMTK(neighbors(G, u), N));
  end
  u = maxidx(score);
  order(i) = u;
  numbered(u) = true;
  
  % Now check that the graph is chordal
  % We require that nbrs(u) intersect numbered is complete
  pa = intersectPMTK(neighbors(G,u), order(1:i-1));
  if ~isequal(G(pa,pa), ones(length(pa)))
    chordal = false;
    return;
  end
  
  % Stuff to find max cliques
  C{i} = [pa i];
  numpa(i) = length(pa);
end

% This code fragment has the same effect as chordal2RipCliques
% Node i is a ladder if numpa(i) > numpa(i+1) or i=d
% See p56 of Cowell et al 1999 Algo 4.11
isLadder = false(1,d);
for i=1:(d-1)
  isLadder(i) = numpa(i) >= numpa(i+1);
end
isLadder(d) = true;
cliques = C(isLadder);


end
