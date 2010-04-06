function model = hmmGaussFitEm(X, nstates, varargin)
% Fit an Hmm to Gaussian observations using EM.
%% Inputs
% X        - a cell array of observations;
%            each observation is d-by-seqLength.
%            
%
% nstates  - the number of hidden states.
%
%% Output
% model is a struct with fields, pi, A, emission, nstates.
%%
[ tol       , ...
    maxIter   , ...
    verbose   , ...
    pi0       , ...
    transmat0 , ...
    emission0   ...
    ] = process_options(varargin ,...
    'tol'      , 1e-4          ,...
    'maxIter'  , 100           ,...
    'verbose'  , true          ,...
    'pi0'      , []            ,...   % initial guess for starting state dist
    'transmat0', []            ,...   % initial guess for the transmat
    'emission0', []);                 % initial guess for the emission dists
X = colvec(X); 
nobs = numel(X);
%% Initialize
stackedData = cell2mat(X')';
seqidx      = cumsum([1, cellfun(@(seq)size(seq, 2), X')]);
seqidx      = seqidx(1:end-1);
if isempty(transmat0)
    transmat = normalize(rand(nstates, nstates), 2); % Each row sums to one
else
    transmat = transmat0;
end
if isempty(pi0)
    startDist = normalize(rand(1, nstates));
else
    startDist = pi0;
end
if isempty(emission0)
    % Fit on random perturbations of the data, ignoring temporal structure.
    emission = cell(nstates, 1);
    for i=1:nstates
        data        = stackedData + randn(size(stackedData));
        emission{i} = gaussFit(data);
    end
else
    emission = emission0;
end
%% Setup loop
it = 1;
currentLL   = -inf;
startCounts = zeros(1, nstates);
transCounts = zeros(nstates, nstates);
weights     = zeros(size(stackedData, 1), nstates);
while true
    previousLL = currentLL;
    [currentLL, startCounts(:), transCounts(:), weights(:)] = deal(0);
    for i=1:nobs
        obs       = X{i}';
        m.pi      = startDist; m.emission = emission; 
        m.nstates = nstates  ; m.A        = transmat; 
        [loglik, alpha, beta, gamma, B] = hmmGaussInfer(m, obs);
        currentLL = currentLL + sum(loglik);
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
    startDist = normalize(startCounts);
    transmat  = normalize(transCounts, 2);
    %% Observation distributions
    for j=1:nstates
        w    = weights(:, j);
        n    = sum(w, 1);
        xbar = sum(bsxfun(@times, stackedData, w))'/n;  % bishop eq 13.20
        Xc   = bsxfun(@minus, stackedData, xbar');
        XX   = bsxfun(@times, Xc, w)'*Xc/n;
        emission{j}.mu    = xbar;
        emission{j}.Sigma = XX;
    end
    %% Check Convergence
    if verbose, fprintf('%d\t loglik: %g\n', it, currentLL ); end
    it = it+1;
    if currentLL < previousLL
        warning('hmmGaussFitEm:LLdecrease',   ...
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
