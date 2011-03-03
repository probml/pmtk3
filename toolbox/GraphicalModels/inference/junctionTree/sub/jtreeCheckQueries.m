function ok = jtreeCheckQueries(jtree, queries)
%% Return true if all of the queries are within cliques of the jtree

% This file is from pmtk3.googlecode.com

ok = false;
queries = cellwrap(queries);
cliqueLookup = jtree.cliqueLookup;
nqueries = numel(queries);
for i = 1:nqueries
    if ~any(all(cliqueLookup(queries{i}, :), 1)); return; end
end
ok = true;
end

