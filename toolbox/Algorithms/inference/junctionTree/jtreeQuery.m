function bels = jtreeQuery(jtree, queries)
%% Query a calibrated jtree for marginals
% Multiple queries can be requested in a cell array

% This file is from pmtk3.googlecode.com


queries      = cellwrap(queries); 
cliques      = jtree.cliques;
cliqueLookup = jtree.cliqueLookup;
nqueries     = numel(queries);

bels = cell(nqueries, 1);
for i=1:nqueries
    q = queries{i};
    candidates = find(all(cliqueLookup(q, :), 1));
    if isempty(candidates)
        if numel(q) == 1 && q <= jtree.nvars 
            % var was sliced out of existence by jtreeSliceCliques
            % which means it was observed, so we return an empty factor. 
            bels{i} = tabularFactorCreate(1, q); 
            continue; 
        else
            error('out-of-clique query. Unless you called this function directly, you have probably queried a node that you have already conditioned on, (clamped).'); 
        end
    end
    cliqueNdx  = candidates(minidx(cellfun('length', cliques(candidates))));
    tf         = tabularFactorMarginalize(cliques{cliqueNdx}, q);
    bels{i}    = tabularFactorNormalize(tf);
end
if nqueries == 1, bels = bels{1}; end



end
