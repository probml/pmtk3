function model = hmmDiscreteFitEm(X, nstates, varargin)
% Fit an Hmm to discrete observations using EM.
%% Inputs
% X        - a cell array of observations;
%            each observation is 1-by-seqLength.
%
%
% nstates  - the number of hidden states.
%
%% Output
% model is a struct with fields, pi, A, emission, nstates.
%%
[ tol                 , ...
    maxIter           , ...
    verbose           , ...
    pi0               , ...
    transmat0         , ...
    emission0         , ...
    piPseudoCounts    , ...
    transPseudoCounts , ...
    obsPseudoCounts     ...
    ] = process_options(varargin ,...
    'tol'      , 1e-7          ,...
    'maxIter'  , 100           ,...
    'verbose'  , true          ,...
    'pi0'      , []            ,...   % initial guess for starting state dist
    'transmat0', []            ,...   % initial guess for the transmat
    'emission0', []            ,...   % initial guess for the emission dists
    'piPseudoCounts'   , []    ,...
    'transPseudoCounts', []    ,...
    'obsPseudoCounts'  , []);
X = colvec(X);
if ~iscell(X), X = {X}; end
nobs = numel(X);
stackedData = cell2mat(X')';
seqidx      = cumsum([1, cellfun(@(seq)size(seq, 2), X')]);
seqidx      = seqidx(1:end-1);

if isempty(piPseudoCounts)
    piPseudoCounts = 2*ones(1, nstates);
end
if isempty(transPseudoCounts)
    transPseudoCounts = ones(nstates, nstates);
end
piPseudoCounts = rowvec(piPseudoCounts);
if diff(size(transPseudoCounts))
    transPseudoCounts = repmat(rowvec(transPseudoCounts), nstates, 1);
end
nobsStates = nunique(stackedData);
if isempty(obsPseudoCounts)
    obsPseudoCounts = 2*ones(nobsStates, 1);
end


%% Initialize
if isempty(transmat0)
    transmat = normalize(rand(nstates, nstates) + transPseudoCounts -1, 2); % Each row sums to one
else
    transmat = transmat0;
end
if isempty(pi0)
    startDist = normalize(rand(1, nstates) + piPseudoCounts - 1);
else
    startDist = pi0;
end
if isempty(emission0)
    % init each emission dist on a random partition of the data, ignoring
    % temporal structure.
    emission = cell(nstates, 1);
    dataPart = randsplit(colvec(stackedData), nstates);
    
    for i=1:nstates
        data = dataPart{i};
        randWeights = normalize(rand(length(data), 1));
        emission{i} = discreteFit(data, obsPseudoCounts, randWeights, nobsStates);
    end
else
    emission = emission0;
end
%% Setup loop
it = 1;
currentLL   = -inf;
startCounts = zeros(1, nstates);
transCounts = zeros(nstates, nstates);
weights     = zeros(length(stackedData), nstates);
while true
    previousLL = currentLL;
    [currentLL, startCounts(:), transCounts(:), weights(:)] = deal(0);
    for i=1:nobs
        obs       = colvec(X{i});
        m.pi      = startDist; m.emission = emission;
        m.nstates = nstates  ; m.A        = transmat;
        [gamma, loglik, alpha, beta, B] = hmmDiscreteInfer(m, obs);
        currentLL = currentLL + loglik;
        %% Distribution over starting states
        startCounts = startCounts + gamma(:, 1)';
        %% State transition matrix
        xi_summed = hmmComputeTwoSlice(alpha, beta, transmat, B);
        transCounts = transCounts + xi_summed;
        %% Data weights
        sz  = size(gamma, 2);
        idx = seqidx(i);
        ndx = idx:idx+sz-1;
        weights(ndx, :) = weights(ndx, :) + gamma';
    end
    startDist = normalize(startCounts + piPseudoCounts - 1);
    transmat  = normalize(transCounts + transPseudoCounts - 1, 2);
    %% Observation distributions
    for j=1:nstates
        emission{j} = discreteFit(colvec(stackedData), obsPseudoCounts, weights(:, j));
    end
    %% Check Convergence
    if verbose, fprintf('%d\t loglik: %g\n', it, currentLL ); end
    it = it+1;
    if currentLL < previousLL
        warning('hmmDiscreteFitEm:LLdecrease',   ...
            'The log likelihood has decreased!');
    end
    converged = convergenceTest(currentLL, previousLL, tol) || it > maxIter;
    if converged, break; end
end
model.pi = startDist;
model.A  = transmat;
model.emission = emission;
model.nstates = nstates;
end
