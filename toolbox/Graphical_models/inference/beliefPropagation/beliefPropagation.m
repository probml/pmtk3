function bels = beliefPropagation(cg, varargin)
%% Belief propagation
%
%%
[maxIter, tol] = process_options(varargin, 'maxIter', 100, 'tol', 1e-3);

Tfac    = cg.Tfac; 
nfacs   = numel(Tfac);
nstates = cg.nstates; 
G       = mkSymmetric(cg.G); 
nbrs    = cell(nfacs, 1); 
for i=1:nfacs
   nbrs{i} = neighbors(G, i);  
end
sepSets = cell(nfacs, nfacs); 
for i = 1:nfacs
    domi = Tfac{i}.domain;
    for j = i+1:nfacs
        I       = intersectPMTK(domi, Tfac{j}.domain); 
        sepSets{i, j} = I;
        sepSets{j, i} = I; 
    end
end

messages    = initializeMessages(sepSets, nstates);

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
    iter = iter + 1;
end
end