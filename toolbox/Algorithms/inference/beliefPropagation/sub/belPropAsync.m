function [bels, converged] = belPropAsync(cg, varargin)
%% Belief propagation with a simple asynchronous update schedule 
% By asynchronous, we mean that a node can update itself without having to
% wait for everyone else to first be ready. A node is ready once it has
% messages from each of its neighbors. 
% See beliefPropagation 
%% setup

% This file is from pmtk3.googlecode.com

[maxIter, tol, lambda, convFn]  = process_options(varargin, ...
    'maxIter'       , 100  , ...
    'tol'           , 1e-3 , ...
    'dampingFactor' , 0.5  , ...
    'convFn'        , []);
%%
Tfac            = cg.Tfac;
nfacs           = numel(Tfac);
[nbrs, sepSets] = computeNeighbors(cg); 
messages        = initializeMessages(mkSymmetric(cg.G), sepSets, cg.nstates);
converged       = false;
iter            = 1;
bels            = Tfac;
Nnbrs           = cellfun('length', nbrs)';
assert(all(Nnbrs)); % does not support disconnected graphs
msgCounter      = zeros(1, nfacs); 
Q               = 1:nfacs;           % initially everyone is in the queue. 
while ~converged && iter <= maxIter 
    oldBels        = bels; 
    oldMessages    = messages;
    leftToSend     = true(1, nfacs);            
    while any(leftToSend) 
        i       = Q(1); 
        Q(1)    = []; %dequeue
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
            if msgCounter(j) == Nnbrs(j)
                msgCounter(j) = 0;
                Q(end+1) = j; %#ok enqueue
            end
        end
        leftToSend(i)  = false; 
        msgCounter(i)  = 0; 
    end
    converged = all(cellfun(@(O, N)approxeq(O.T, N.T, tol), oldBels, bels));
    if ~isempty(convFn) %optionally monitor convergence
       convFn(oldMessages, messages);  
    end
    iter      = iter+1;
end
end
