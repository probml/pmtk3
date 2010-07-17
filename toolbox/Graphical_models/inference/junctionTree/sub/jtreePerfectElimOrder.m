function order = jtreePerfectElimOrder(G)
%% Compute the perfect elimination order of a chordal graph
% G must be chordal - no check is performed to ensure this
% See checkChordal
%% 
G     = logical(G); 
G     = setdiag(G, true); 
d     = size(G, 1); 
order = zeros(1, d); 

numbered    = false(1, d); 
order(1)    = 1; 
numbered(1) = true; 
for i=2:d
    U     = find(~numbered); 
    n     = numel(U);
    score = zeros(1, n); 
    for j=1:n
        k = U(j); 
         % this is much faster than length(intersectPMTK(neighbors(G, u), N));
        score(j) = sum((G(k, :) | G(:, k)') & numbered); 
    end
    u = U(maxidx(score)); 
    order(i) = u;
    numbered(u) = true; 
end


test = false;
if test
    [elim, ischordal] = perfectElimOrder(G);
    assert(ischordal); 
    assert(isequal(elim, order));
end


end