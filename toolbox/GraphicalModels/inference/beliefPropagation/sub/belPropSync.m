function [bels, converged] = belPropSync(cg, varargin)
%% Belief propagation with a simple synchronous update schedule 
% By synchronous we mean nodes are all updated at the same time. 
% This is sometimes called a systolic update schedule since all of the
% nodes alternate between 'sending out' and 'sucking in'. 
% 
%  See beliefPropagation 
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
while ~converged && iter <= maxIter
    %% distribute (send out)
    % - everyone sends out messages before anyone collects - 
    % In computing the message from i to j, we exclude j's previous message
    % to i, rather than dividing it out later. 
    oldMessages = messages; 
    for i=1:nfacs
        N = nbrs{i};
        for j=N
            F              = [Tfac(i); messages(setdiffPMTK(N, j), i)];
            psi            = tabularFactorNormalize(tabularFactorMultiply(F));
            Mnew           = tabularFactorMarginalize(psi, sepSets{i, j});
            Mold           = oldMessages{i, j}; 
            messages{i, j} = tabularFactorConvexCombination(Mnew, Mold, lambda); 
        end
    end
    %% collect (suck in)
    oldBels = bels;
    for i=1:nfacs
        M       = [Tfac(i); messages(nbrs{i}, i)];
        bels{i} = tabularFactorNormalize(tabularFactorMultiply(M));
    end
    %% check convergence
    converged = all(cellfun(@(O, N)approxeq(O.T, N.T, tol), oldBels, bels));
    if ~isempty(convFn) % optionally monitor convergence
       convFn(oldMessages, messages);  
    end
    iter = iter+1;
end
end
