function [model, loglikHist] = mixDiscreteFitEM(X, nmix,  varargin)
%% Fit a mixture of products of discrete distributions via EM.
%
%% Inputs
% X(i, j)   - is the ith case from the jth distribution, an integer in 1...C
% nmix      - the number of mixture components to use
%
%% Optional (named) Inputs
% 'saveMemory'  - it true, (default = false) slower more memory efficient
%               code is run. Use this if you get out of memory errors. 
%
% 'distPrior'   - pseudo counts for the cluster conditional densities
% 'mixPrior'    - pseudo counts for the mixture distribution
%
%%
% *** See emAlgo() for optional EM related arguments ***
%
%% Outputs
% Returns a struct with fields
%    model.T(c,d,j) = p(xd=c|z=j) nstates*ndistributions*nmixtures
% loglikHist - log likelihood history
%% Setup

nstates = max(X(:));
[maxIter, convTol, verbose, saveMemory, distPrior, mixPrior] = ...
    process_options(varargin        , ...
    'maxIter'    , 100              , ...
    'convTol'    , 1e-3             , ...
    'verbose'    , false            , ...
    'saveMemory' , false            , ...
    'distPrior'  , ones(nstates, 1) , ...
    'mixPrior'   , ones(1, nmix)    );



%% Fit
initFn = @(X)init(X, nmix, nstates, mixPrior, distPrior, saveMemory);
[model, loglikHist] = emAlgo(X, initFn, @estep, @mstep, [], ...
    'maxIter', maxIter, 'convTol', convTol, 'verbose', verbose);
end

function model = init(X, nmix, nstates, mixPrior, distPrior, saveMemory)
%% Initialize
% by randomly partitioning the data, fitting each partition separately
% and then adding noise.
d = size(X, 2); 
T = zeros(nstates, d, nmix);
Xsplit = randsplit(X, nmix);
for k=1:nmix
    m = discreteFit(Xsplit{k});
    T(:, :, k) = m.T;
end
T = normalize(T + 0.2*rand(size(T)), 1); % add noise
mixweight = normalize(10*rand(1, nmix) + rowvec(mixPrior));
model = structure(mixweight, T, saveMemory, mixPrior, distPrior);
end


function model = mstep(model, ess)
model.T = normalize(bsxfun(@plus, ess.counts-1, model.distPrior), 1);
model.mixweight = normalize(ess.Rk + model.mixPrior - 1);
end

function [ess, loglik] = estep(model, X)
[N, D]  = size(X);  %#ok
[nstates, d, nmix] = size(model.T);
[z, Rik, L] = mixDiscreteInfer(model, X); 
loglik = (sum(L) + sum(log(model.mixPrior + eps)) + ...
          sum(log(model.distPrior + eps))) / N;
counts    = zeros(nstates, d, nmix);
% counts(c,d,j) = p(xd=c|z=j)
if model.saveMemory
    for c=1:nstates
        for j = 1:nmix
            counts(c, :, j) = sum(bsxfun(@times, (X==c), Rik(:, j)));
        end
    end
else
    % vectorized solution is faster but takes up much more memory
    RikPerm = permute(Rik, [1, 3, 2]); % insert singleton dimension for bsxfun
    for c=1:nstates  % call to bsxfun returns a matrix of size n-by-d-nmix
        counts(c, :, :) = sum(bsxfun(@times, (X == c), RikPerm), 1);
    end
end
ess.counts = counts;
ess.Rk = sum(Rik);
end
