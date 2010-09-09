function bels = queryCliques(cliques, queries, cliqueLookup)
%% Query a cell array of cliques

% This file is from pmtk3.googlecode.com


if nargin < 3
    cliqueLookup = createFactorLookupTable(cliques); 
end
% let jtreeQuery do the work, even though the cliques may not represent 
% a junction tree. 
bels = jtreeQuery(structure(cliques, cliqueLookup), queries); 

end
