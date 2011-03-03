function [nbrs, sepSets] = computeNeighbors(cg)
%% Compute the neighbors, for each clique
%
%% Input
%
% cg        - a cliqueGraph see cliqueGraphCreate
%
%% Output    
%
% nbrs        - cliques(N{i}) are the neighbors of the ith clique, i.e. the
%              cliques whose domain overlaps with clique i. 
%
% sepSets     - the separating sets, i.e. the domain intersections of
%               the cliques. 
%%

% This file is from pmtk3.googlecode.com

Tfac      = cg.Tfac;
facStruct = [Tfac{:}];
doms      = {facStruct.domain};
nfacs     = numel(Tfac);
G         = mkSymmetric(cg.G);
nbrs      = cell(nfacs, 1);
for i=1:nfacs
    nbrs{i} = neighbors(G, i);
end
sepSets = cell(nfacs, nfacs);
for i = 1:nfacs
    domi = doms{i};
    for j = i+1:nfacs
        I = intersectPMTK(domi, doms{j});
        sepSets{i, j} = I;
        sepSets{j, i} = I;
    end
end
end
