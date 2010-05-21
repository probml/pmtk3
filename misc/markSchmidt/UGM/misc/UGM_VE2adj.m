function [adj] = UGM_VE2adj(V,E,edgeEnds)

nNodes = length(V)-1;
adj = zeros(nNodes);

for n = 1:nNodes
    edges = E(V(n):V(n+1)-1);
        
    for e = edges(:)'
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);
        adj(n1,n2) = 1;
        adj(n2,n1) = 1;
    end
end
