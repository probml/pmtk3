function [N, S, nstates, G] = computeNeighbors(cliques)
%% Compute the neighbors, for each clique
%
%% Input
%
% cliques    -  a cell array of tabular factors, which implicitly defines a
%               factor graph. The cliques are not necessarily maximal. 
%
%% Output    
%
% N          - cliques(N{i}) are the neighbors of the ith clique, i.e. the
%              cliques whose domain overlaps with clique i. 
%
% S          - S are the separating sets, i.e. the domain intersections of
%             the cliques. 
%
% nstates(k) - is the number of states for variable k
%
% G          - G(i, j) = G(j, i) = true iff S{i, j} = S{j, i} is non-empty
%%
ncliques = numel(cliques);
S        = cell(ncliques, ncliques); 
C        = [cliques{:}];
fullDom  = uniquePMTK([C.domain]); 
nstates = zeros(1, max(fullDom)); 
doms     = {C.domain};
G        = false(ncliques, ncliques); 
for i = 1:ncliques
    domi = doms{i}; 
    nstates(domi) = cliques{i}.sizes; 
    for j = i+1:ncliques
        I       = intersectPMTK(domi, doms{j}); 
        S{i, j} = I;
        S{j, i} = I; 
        G(i, j) = ~isempty(I);
    end
end
G = mkSymmetric(G); 
N = cell(ncliques, 1); 
for i=1:ncliques
   N{i} = neighbors(G, i);  
end
end


