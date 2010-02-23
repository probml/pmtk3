function model = mixDiscreteFitEM(X, nmix, distPrior, mixPrior)
% Fit a mixture of products of discrete distributions via EM. 
% X must be in 1:C. 
%
% X(i, j) is the ith case from the jth distribution
% nmix - the number of mixture components to use
% distPrior - prior pseudoCounts for the component distributions.
% mixPrior  - prior on the mixture weights. 
%
% model.T is nstates-by-ndistributions-by-nmixtures
%
%% Setup
[n, d]  = size(X); 
nstates = max(X(:)); 
if nargin < 3, distPrior = ones(nstates, 1); end
if nargin < 4, mixPrior  = ones(1, nmix);    end
distPrior = colvec(distPrior); 
mixPrior  = rowvec(mixPrior);
%% Initial M-step using Kmeans
[mu, assign] = kmeansFit(X, nmix); %#ok
mixweight = normalize(rowvec(histc(assign, 1:nmix)) + mixPrior - 1);
T = zeros(nstates, d, nmix); 
for k=1:nmix
    counts = histc(X(assign==k, :), 1:nstates);
    T(:, :, k) = normalize(bsxfun(@plus, counts, (distPrior-1)), 1);  
end
%% Loop setup
currentLL = -inf;
it        = 0; 
maxiter   = 1000; 
logRik    = zeros(n, nmix);
Lij       = zeros(n, d);
verbose   = true;
%% Enter EM loop
while true
    previousLL = currentLL;
    %% E-step
    for k=1:nmix
        for j=1:d
            Lij(:, j) = log(T(X(:, j), j, k) + eps);
        end
        logRik(:, k) = log(mixweight(k)+eps) + sum(Lij, 2);
    end
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
    converged = convergenceTest(currentLL, previousLL) || it > maxiter; 
    if converged, break; end
    %% M-step
    counts = zeros(nstates, d, nmix); 
    for k=1:nmix
        for c=1:nstates
            counts(c, :, k) = sum(bsxfun(@times, (X == c), Rik(:, k)), 1);
        end
    end
    T = normalize(T,  1);
    mixweight = normalize(sum(Rik) + mixPrior - 1); 
end
%% Return the model
model.T = T;
model.mixweight = mixweight;
model.nstates = nstates;
model.d = d;
model.nmix = nmix;