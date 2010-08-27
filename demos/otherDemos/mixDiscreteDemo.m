%% Simple test of a discrete mixture model
%% Create Data
setSeed(13);
nmix = 6; 
truth.nmix = nmix;
truth.d = 80;
truth.nstates = 8;
truth.mixweight = normalize(rand(1, truth.nmix));
truth.T = normalize(rand(truth.nstates, truth.d, truth.nmix), 1);
nsamples = 1000;
[X, y] = mixDiscreteSample(truth, nsamples); 

%% Fit
[model, llhist] = mixModelFit(X, nmix, 'discrete', 'verbose', true);
%% Compare against the best permutation of the cluster labels.
ypred = mixModelMapLatent(model, X);
allperms = perms(1:truth.nmix);
nperms = size(allperms, 1); 
errors = zeros(nperms, 1); 
for i=1:nperms
    errors(i) = sum(y ~= allperms(i, ypred)');
end
ypred = allperms(minidx(errors), ypred)';

nerrors = sum(y~=ypred)
