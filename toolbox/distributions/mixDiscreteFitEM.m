function model = mixDiscreteFitEM(X, nmix, distPrior, mixPrior)
% Fit a mixture of products of discrete distributions via EM. 
%
% X(i, j) is the ith case from the jth distribution
% nmix - the number of mixture components to use
% distPrior - prior pseudoCounts for the component distributions.
% mixPrior  - prior on the mixture weights. 
%

%% initialize
[n, d] = size(X);
nstates = max(X(:));
if nargin < 3, distPrior = ones(1, nstates); end
if nargin < 4, mixPrior  = ones(1, nmix); end
mixweight  = normalize(rand(1, nmix));
perm = randperm(n);
batchSize = max(1, floor(n/nmix));
T = zeros(nstates, d, nmix); 
for i=1:nmix
    start = (i-1)*batchSize+1;
    initdata = X(perm(start:start+batchSize-1), :);
    m = discreteFit(initdata, distPrior);
    T(:, :, i) = m.T;
end
%% EM
converged = false;
[Rik, currentLL] = inferLatent();
it = 0; maxiter = 1000; 
while(not(converged))
    previousLL = currentLL;
    for j=1:nmix
        m = discreteFit(X, distPrior, Rik(:, j));
        T(:, :, j) = m.T;
    end
    it = it+1;
    [Rik, currentLL] = inferLatent();
    converged = convergenceTest(currentLL, previousLL) || it > maxiter;
end

model.nmix = nmix;
model.K = nstates;
model.d = d;
model.T = T;

    function [Rik, LL] = inferLatent()
        % Rik(i, k) = p(H=k | X(i, :), params)
        logRik = zeros(n, nmix);
        tmpModel = m; 
        for k=1:nmix
            tmpModel.T = T(:, :, k); 
            logRik(:, k) = log(mixweight(k)+eps) + discreteLogprob(tmpModel, X) + log(mixPrior(k));
        end
        [logRik, LL] = normalizeLogspace(logRik);
        Rik = exp(logRik);
    end
end