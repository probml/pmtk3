function B = mkSoftEvidence(localCPD, X)
%% Make a soft evidence matrix B(j, t) = p(X(:, t) | S(t) = j, localCPD)
% where S(t) denotes the state of node t. 
%
%% Inputs:
%
% localCPD - a struct as created by e.g. gaussCpdCreate, representing a
%            local conditional probability distribution in a directed
%            graphical model.
%
% X       -  a dense matrix of size d-by-nnodes, where nnodes is e.g. the
%            number of nodes 'parameter-tied' to localCPD, or e.g. the
%            number of time steps in an hmm model, i.e. the sequence
%            length.
%
%  Use NaN's in X for unobserved nodes. The corresponding column of B contain
%  NaNs.
%%

nstates  = localCPD.nstates;
observed = ~any(isnan(X), 1);
Xobs     = X(:, observed);
B = nan(nstates, size(X, 2));

switch lower(localCPD.cpdType)
    case 'tabular'
        T = localCPD.T;
        B(:, observed) = T(:, Xobs'); % must have only one parent
    case 'condgauss'
        mu    = localCPD.mu;
        Sigma = localCPD.Sigma;
        for j=1:nstates
            B(j, observed) = rowvec(exp(gaussLogprob(mu(:, j), Sigma(:, :, j), Xobs')));
        end
    otherwise
        error('%s is not a recognized CPD type', localCPD.cpdType);
end
end