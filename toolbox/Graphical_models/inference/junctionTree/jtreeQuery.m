function [logZ, bels] = jtreeQuery(jtree, queries)
%% Query a calibrated jtree for marginals
% Multiple queries can be requested in a cell array

queries      = cellwrap(queries); 
cliques      = jtree.cliques;
cliqueLookup = jtree.cliqueLookup;
nqueries     = numel(queries);

bels = cell(nqueries, 1);
Z  = zeros(nqueries, 1);
for i=1:nqueries
    q = queries{i};
    candidates = find(all(cliqueLookup(q, :), 1));
    if isempty(candidates), error('out-of-clique query'); end
    cliqueNdx  = candidates(minidx(cellfun('length', cliques(candidates))));
    tf         = tabularFactorMarginalize(cliques{cliqueNdx}, q);
    [bels{i}, Z(i)] = tabularFactorNormalize(tf);
end
if nqueries == 1, bels = bels{1}; end
logZ = log(Z + eps);
logZ = logZ(1); % all the same

end