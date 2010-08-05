function [bels, converged] = belPropSync(cg, varargin)
%% Belief propagation with a simple synchronous update schedule 
% A node updates itself and then sends out messages to its neighbors 
% only once it has received messages from all of its neighbors.
% See beliefPropagation 
%% setup
[maxIter, tol, lambda]  = process_options(varargin, ...
    'maxIter'       , 100  , ...
    'tol'           , 1e-3 , ...
    'dampingFactor' , 0.5);
%%
Tfac            = cg.Tfac;
nfacs           = numel(Tfac);
[nbrs, sepSets] = computeNeighbors(cg); 
messages        = initializeMessages(sepSets, cg.nstates);
converged       = false;
iter            = 1;
bels            = Tfac;
Nnbrs           = cellfun('length', nbrs)';
msgCounter      = zeros(1, nfacs); % keep track of how many messages a node 
                                   % has received. 
while ~converged && iter <= maxIter 
    oldBels        = bels; 
    oldMessages    = messages;
    leftToSend     = true(1, nfacs); % make sure we give everyone a chance 
                                     % to send, and that no one sends twice
                                     % in a single iteration, even if
                                     % ready.
                                     
    readyToSend = true(1, nfacs); % initially everyone is ready to send
    while any(leftToSend) 
        i       = find(readyToSend & leftToSend, 1, 'first')
        N       = nbrs{i};
        M       = [Tfac(i); messages(N, i)];
        bels{i} = tabularFactorNormalize(tabularFactorMultiply(M));
        for j = N
            F              = [Tfac(i); messages(setdiffPMTK(N, j), i)];
            psi            = tabularFactorNormalize(tabularFactorMultiply(F));
            Mnew           = tabularFactorMarginalize(psi, sepSets{i, j});
            Mold           = oldMessages{i, j};
            messages{i, j} = tabularFactorConvexCombination(Mnew, Mold, lambda);
            msgCounter(j)  = msgCounter(j) + 1;
        end
        leftToSend(i)  = false; 
        msgCounter(i)  = 0; 
        readyToSend(i) = false; 
        readyToSend    = readyToSend | msgCounter == Nnbrs; % ready once all msgs have been collected
    end
    converged = all(cellfun(@(O, N)approxeq(O.T, N.T, tol), oldBels, bels));
    iter      = iter+1;
end
end