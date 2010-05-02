function [model, loglikHist] = mixDiscreteFitEM(X, nmix,  varargin)
% Fit a mixture of products of discrete distributions via EM.
%
% X(i, j)   - is the ith case from the jth distribution, an integer in 1...C
% nmix      - the number of mixture components to use
%  See emAlgo() for optional arguments.

% Returns a struct with fields
%    T(c,d,j) = p(xd=c|z=j) nstates*ndistributions*nmixtures
%    mixweight


% Setup
[n, d]  = size(X); %#ok
nstates = max(X(:));
[maxIter, convTol, verbose, saveMemory, distPrior, mixPrior] = process_options(varargin,...
  'maxIter', 100, 'convTol', 1e-3, 'verbose', false, 'saveMemory', false, ...
  'distPrior', ones(nstates, 1), 'mixPrior', ones(1, nmix));

% Initialize
% by randomly partitioning the data, fitting each partition separately
% and then adding noise.
T = zeros(nstates, d, nmix);
Xsplit = randsplit(X, nmix);
for k=1:nmix
  m = discreteFit(Xsplit{1});
  T(:, :, k) = m.T;
end
T = normalize(T + 0.2*rand(size(T)), 1); % add noise
mixweight = normalize(10*rand(1, nmix) + rowvec(mixPrior));
model = structure(mixweight, T, saveMemory, mixPrior, distPrior);


% Fit
[model, loglikHist] = emAlgo(model, X, @estep, @mstep, [], ...
  'maxIter', maxIter, 'convTol', convTol, 'verbose', verbose);

end

function model = mstep(model, ess)
model.T = normalize(bsxfun(@plus, ess.counts-1, model.distPrior), 1);
model.mixweight = normalize(ess.Rk + model.mixPrior - 1);
end

function [ess, loglik] = estep(model, X)
[N,D]  = size(X); %#ok
[nstates, d, nmix] = size(model.T);
[z, Rik, L] = mixDiscreteInfer(model, X); %#ok
loglik = (sum(L) + sum(log(model.mixPrior + eps)) + sum(log(model.distPrior + eps))) / N;
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
