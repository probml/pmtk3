function logB = mkSoftEvidence(localCPD, X)
%% Make a soft evidence matrix logB(j, t) = log p(X(:, t), S(t) = j)
% (unnormalized), where S(t) denotes the state of node t. 
%
%% Inputs:
%
% localCPD - a struct as created by e.g. gaussCpdCreate, representing a
%            local conditional probability distribution in a directed
%            graphical model.
%
% X       -  a dense matrix of size d-by-nnodes, where nnodes is e.g. the
%            number of nodes 'parameter-tied' to localCPD, or e.g. the
%            number of time steps in an hmm model, (the sequence
%            length).
%
%  Use NaN's in X for unobserved nodes. The corresponding column of B 
% will contain NaNs.
%%

% This file is from pmtk3.googlecode.com

assert(size(X, 1) == localCPD.d); 
[d, seqlen] = size(X); 
observed    = ~any(isnan(X), 1);
Xobs        = X(:, observed);
switch lower(localCPD.cpdType)
    case 'tabular'
        
        T              = localCPD.T;
        nstates        = size(T, 1); 
        B              = nan(nstates, seqlen);
        B(:, observed) = T(:, Xobs); % must have only one parent
        logB = log(B); 
        
    case 'condgauss'
        
        nstates  = localCPD.nstates;
        logB     = nan(nstates, seqlen);
        mu       = localCPD.mu;
        Sigma    = localCPD.Sigma;
        XobsT    = Xobs';
        for j=1:nstates
            logB(j, observed) = gaussLogprob(mu(:, j), Sigma(:, :, j), XobsT);
        end
        
    case 'condmixgausstied'
        
        nstates = localCPD.nstates;
        nmix    = localCPD.nmix;
        mu      = localCPD.mu;
        Sigma   = localCPD.Sigma;
        M       = localCPD.M;  % nstates-by-nmix
        logM    = log(M);
        logP    = nan(nmix, seqlen);
        XobsT   = Xobs';
        for k=1:nmix
            logP(k, observed) = gaussLogprob(mu(:, k), Sigma(:, :, k), XobsT);
        end
        logB = nan(nstates, seqlen);
        for j = 1:nstates
            logBj = bsxfun(@plus, logM(j, :)', logP(:, observed));
            logB(j, observed) = logsumexp(logBj, 1);
        end
        
    case 'condstudent'
        
        nstates  = localCPD.nstates;
        logB     = nan(nstates, seqlen);
        mu       = localCPD.mu;
        Sigma    = localCPD.Sigma;
        dof      = localCPD.dof; 
        XobsT    = Xobs';
        for j=1:nstates
            logB(j, observed) = ...
                studentLogprob(mu(:, j), Sigma(:, :, j), dof(j), XobsT);
        end
        
    case 'conddiscreteprod'
        
        T  = localCPD.T;
        [nstates, nObsStates, d]  = size(T); 
        % Make sure data is 1..K ie no 0's
        %Xobs = canonizeLabels(Xobs, 1:nObsStates); % KPM 3/30/11
        %Xobs = canonizeLabels(Xobs); % KPM 4/2/11
        logB           = nan(nstates, seqlen);
        logT           = log(T);   % T is of size nstates-nObsStates-d
        L = zeros(nstates, numel(observed), d);
        for j = 1:d
            L(:, :, d) = logT(:, Xobs(j, :), j);
        end
        logB(:, observed) = sum(L, 3); 
        
    otherwise
        error('%s is not a recognized CPD type', localCPD.cpdType);
end
end
