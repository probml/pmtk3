function [order, chordal] = perfectElimOrder(G)
%% Compute the perfect elimination order of a chordal graph
% Uses the Maximum Cardinality Search algorithm
% chordal = false if graph is not chordal 
%
% See perfectElimDemo for an example
%% 
G     = logical(G); 
G     = setdiag(G, true); % for chordality checking
d     = size(G, 1); 
order = zeros(1, d); 
numbered    = false(1, d); 
order(1)    = 1; 
numbered(1) = true; 
chordal = true;
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
  % We require that nbrs(u) intersect numbered = clique
  pa = intersectPMTK(neighbors(G,u), order(1:i-1));
  if ~isequal(G(pa,pa), ones(length(pa)))
    chordal = false;
    return;
  end
end



end