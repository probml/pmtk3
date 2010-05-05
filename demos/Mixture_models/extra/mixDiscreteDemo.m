%% Simple test of MixDiscreteFitEM
%% Create Data
setSeed(0);
truth.nmix = 6;
truth.d = 80;
truth.nstates = 8;
truth.mixweight = normalize(rand(1, truth.nmix));
truth.T = normalize(rand(truth.nstates, truth.d, truth.nmix), 1);
nsamples = 1000;
[X, y] = mixDiscreteSample(truth, nsamples); 
%% Prior
% use bogus priors just for testing purposes
distPrior = sampleDiscrete(normalize(ones(1, 10)), truth.nstates, 1);
mixPrior  = sampleDiscrete(normalize(ones(1, 10)), 1, truth.nmix);
%% Fit
[model, llhist] = mixDiscreteFitEM(X, truth.nmix, 'verbose', true, 'distPrior', distPrior, 'mixPrior', mixPrior);
%% Compare against the best permutation of the cluster labels.
ypred = mixDiscreteInfer(model, X);
allperms = perms(1:truth.nmix);
nperms = size(allperms, 1); 
errors = zeros(nperms, 1); 
for i=1:nperms
    errors(i) = sum(y ~= allperms(i, ypred)');
end
ypred = allperms(minidx(errors), ypred)';
nerrors = sum(y~=ypred)