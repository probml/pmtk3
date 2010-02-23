function model = mixDiscreteFitEM(X, nmix, distPrior, mixPrior, varargin)
% Fit a mixture of products of discrete distributions via EM.
% X must be in 1:C.
%
% X(i, j)   - is the ith case from the jth distribution
% nmix      - the number of mixture components to use
% distPrior - (optional) prior pseudoCounts for the component distributions.
% mixPrior  - (optional) prior on the mixture weights.
% varargin  - (optional) {'-maxiter', 100, '-tol', 1e-4, '-verbose', true}
%
% Returns a struct with fields T, mixweight, nstates, d, nmix
% model.T is nstates-by-ndistributions-by-nmixtures
%
%% Setup
[n, d]  = size(X);
nstates = max(X(:));
if nargin < 3 || isempty(distPrior), distPrior = ones(nstates, 1); end
if nargin < 4 || isempty(mixPrior) , mixPrior  = ones(1, nmix);    end
distPrior = colvec(distPrior);
mixPrior  = rowvec(mixPrior);
[maxiter, tol, verbose] = processArgs(varargin, '-maxiter', 100, '-tol', 1e-4, '-verbose', true); 
%% Initial M-step using Kmeans
[mu, assign] = kmeansFit(X, nmix); %#ok
mixweight = normalize(rowvec(histc(assign, 1:nmix)) + mixPrior - 1);
T = zeros(nstates, d, nmix);
for k=1:nmix
    counts = histc(X(assign==k, :), 1:nstates);
    T(:, :, k) = normalize(bsxfun(@plus, counts, (distPrior-1)), 1);
end
%% Setup loop
currentLL = -inf;
it        = 0;
Lijk      = zeros(n, d, nmix);
counts    = zeros(nstates, d, nmix);
%% Enter EM loop
while true
    previousLL = currentLL;
    %% E-step
    logT = log(T + eps); 
    for j=1:d
        Lijk(:, j, :) = logT(X(:, j), j, :);
    end
    logRik = bsxfun(@plus, log(mixweight+eps), squeeze(sum(Lijk, 2)));
    L = logsumexp(logRik, 2);
    logRik = bsxfun(@minus, logRik, L);
    Rik = exp(logRik);
    currentLL = (sum(L) + sum(log(mixPrior + eps))) / n;
    %% Check convergence
    if verbose, display(currentLL); end
    it = it+1;
    if currentLL < previousLL
        warning('mixDiscreteFitEM:LLdecrease',   ...
            'The log likelihood has decreased!');
    end
    converged = convergenceTest(currentLL, previousLL, tol) || it > maxiter;
    if converged, break; end
    %% M-step
    % we use the permute function to reshape Rik into size [n, 1, nmix] to
    % to further vectorize using bsxfun.
    for c=1:nstates
        counts(c, :, :) = sum(bsxfun(@times, (X == c), permute(Rik, [1, 3, 2])), 1);
    end
    T = normalize(counts,  1);
    mixweight = normalize(sum(Rik) + mixPrior - 1);
end
%% Return the model
model.T = T;
model.mixweight = mixweight;
model.nstates = nstates;
model.d = d;
model.nmix = nmix;