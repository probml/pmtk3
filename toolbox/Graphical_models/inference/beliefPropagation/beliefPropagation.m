function bels = beliefPropagation(Tfac, varargin)
%% Belief propagation
%
%%
[maxIter, tol]           = process_options(varargin, 'maxIter', 100, 'tol', 1e-2);
[nbrs, sepSets, nstates] = computeNeighbors(Tfac);
messages    = initializeMessages(sepSets, nstates);
nfacs       = numel(Tfac);
bels        = cell(nfacs, 1);
converged   = false;
iter        = 1;
multAndNorm = @(a, b)tabularFactorNormalize(tabularFactorMultiply(a, b)); 
margAndNorm = @(a, b)tabularFactorNormalize(tabularFactorMarginalize(a, b)); 
D           = num2cell((1:nfacs))';

while ~converged && iter <= maxIter
    oldBels = bels;
    psi  = cellfuncell(@(N, i)tabularFactorMultiply(messages(N, i)), nbrs, D); % product of messages
    bels = cellfuncell(multAndNorm, Tfac, psi); 
    converged = iter > 1 && all(cellfun(@(O, N)approxeq(O.T, N.T, tol), oldBels, bels)); 
    if ~converged
        oldMessages = messages;
        for i = 1:nfacs
            for j = nbrs{i}
                M = tabularFactorDivide(psi{i}, oldMessages{j, i});
                M = tabularFactorMultiply(M, Tfac{i});
                messages{i, j} = margAndNorm(M, sepSets{i, j}); 
            end
        end
    end
    iter = iter + 1;
end
end