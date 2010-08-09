function bels = queryCliques(cliques, queries, cliqueLookup)
%% Query a cell array of cliques

if nargin < 3
    cliqueLookup = createFactorLookupTable(cliques); 
end
% let jtreeQuery do the work, even though the cliques may not represent 
% a junction tree. 
bels = jtreeQuery(structure(cliques, cliqueLookup), queries); 

end