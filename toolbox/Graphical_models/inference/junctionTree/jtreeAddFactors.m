function jtree = jtreeAddFactors(jtree, facs)
%% Add factors to an existing jtree
% by multiplying them into the smallest accommodating cliques.
%%
if isempty(facs); return; end
cliques = jtree.cliques;
clqSizes = cellfun('length', cliques);
cliqueLookup = jtree.cliqueLookup;
for i=1:numel(facs)
    f  = facs{i};
    fdom = f.domain;
    candidateCliques = find(all(cliqueLookup(fdom, :), 1));
    if isempty(candidateCliques)
        error('no accomidating clique could be found for facs{%d}: %d', i, fdom); 
    end
    smallest = candidateCliques(minidx(clqSizes(candidateCliques)));
    assert(issubset(fdom, cliques{smallest}.domain)); 
    clq = tabularFactorMultiply(cliques{smallest}, f);
    cliques{smallest} = tabularFactorNormalize(clq); 
    cliqueLookup(fdom, smallest) = 1;
end
jtree.cliques = cliques;
jtree.cliqueLookup = cliqueLookup;
end