function bels = queryCliques(cliques, queries)
%% Query a cell array of cliques

cliqueLookup = createFactorLookupTable(cliques); 
% let jtreeQuery do the work, even though the cliques may not represent 
% a junction tree. 
bels = jtreeQuery(structure(cliques, cliqueLookup), queries); 

end