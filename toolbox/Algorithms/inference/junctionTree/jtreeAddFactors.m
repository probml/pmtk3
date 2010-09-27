function [jtree, logZlocal] = jtreeAddFactors(jtree, facs)
%% Add factors to an existing jtree
% by multiplying them into the smallest accommodating cliques.
%%

% This file is from pmtk3.googlecode.com


if isempty(facs)
    logZlocal = 0;
    return;
end
nfacs = numel(facs); 
Z = zeros(nfacs, 1);
for i=1:nfacs
   [facs{i}, Z(i)] = tabularFactorNormalize(facs{i});  
end
logZlocal = sum(log(Z)); 
    
    

cliques = jtree.cliques;
clqSizes = cellfun('length', cliques);
cliqueLookup = jtree.cliqueLookup;
for i=1:numel(facs)
    f  = facs{i};
    fdom = f.domain;
    candidateCliques = find(all(cliqueLookup(fdom, :), 1));
    if isempty(candidateCliques)
        error('no accomodating clique could be found for facs{%d}: %d', i, fdom); 
    end
    smallest = candidateCliques(minidx(clqSizes(candidateCliques)));
    assert(issubset(fdom, cliques{smallest}.domain)); 
    cliques{smallest} = tabularFactorMultiply(cliques{smallest}, f);
    cliqueLookup(fdom, smallest) = 1;
end
jtree.cliques = cliques;
jtree.cliqueLookup = cliqueLookup;
end
