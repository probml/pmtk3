function bels = beliefPropagation(Tfac, varargin)
%% Belief propagation
%
%%
[maxIter, tol] = process_options(varargin, 'maxIter', 100, 'tol', 1e-3);

[nbrs, sepSets, nstates] = computeNeighbors(Tfac);
messages    = initializeMessages(sepSets, nstates);
nfacs       = numel(Tfac);
bels        = cell(nfacs, 1);
psi         = cell(nfacs, 1); %psi{i} product of messages to i
converged   = false;
iter        = 1;
multAndNorm = @(a, b)tabularFactorNormalize(tabularFactorMultiply(a, b)); 
initPsi     = Tfac; 
for i=1:nfacs
    initPsi{i}.T(:) = 1; 
end
while ~converged && iter <= maxIter
    %% collect
    oldBels = bels;
    for i=1:nfacs
        psi{i} = tabularFactorMultiply([initPsi(i); messages(nbrs{i}, i)]);
        bels{i} = multAndNorm(Tfac{i}, psi{i}); 
    end
    converged = iter > 1 && all(cellfun(@(O, N)approxeq(O.T, N.T, tol), oldBels, bels)); 
    if ~converged
        %% distribute
        oldMessages = messages;
        for i = 1:nfacs
            for j = nbrs{i}
                M = tabularFactorDivide(psi{i}, oldMessages{j, i});
                M = tabularFactorMultiply(M, Tfac{i});
                M = tabularFactorMarginalize(M, sepSets{i, j}); 
                messages{i, j} = tabularFactorNormalize(M); 
            end
        end
    end
    iter = iter + 1
end
end