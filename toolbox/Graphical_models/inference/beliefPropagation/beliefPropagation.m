function bels = beliefPropagation(cg, varargin)
%% Belief propagation
%
%% setup
[maxIter, tol]  = process_options(varargin, 'maxIter', 100, 'tol', 1e-3);
Tfac            = cg.Tfac;
nfacs           = numel(Tfac);
[nbrs, sepSets] = computeNeighbors(cg); 
messages        = initializeMessages(sepSets, cg.nstates);
converged       = false;
iter            = 1;
bels            = Tfac;
while ~converged && iter <= maxIter
    %% distribute
    % In forming the message from i to j, we exclude j's previous message
    % to i, rather than dividing it out later. 
    for i=1:nfacs
        N = nbrs{i};
        for j=N
            M              = [Tfac(i); messages(setdiffPMTK(N, j), i)];
            psi            = tabularFactorMultiply(M);
            psi            = tabularFactorNormalize(psi);
            messages{i, j} = tabularFactorMarginalize(psi, sepSets{i, j});
        end
    end
    %% collect
    oldBels = bels;
    for i=1:nfacs
        B       = tabularFactorMultiply([Tfac(i); messages(nbrs{i}, i)]);
        bels{i} = tabularFactorNormalize(B);
    end
    %% check convergence
    converged = all(cellfun(@(O, N)approxeq(O.T, N.T, tol), oldBels, bels));
    iter = iter+1;
end
end