%% Simple test of a discrete mixture model


% This file is from pmtk3.googlecode.com

setSeed(0);
nmix = 6; 
truth.nmix = nmix;
truth.d = 80;
truth.nstates = 8; % number of observed states
truth.mixweight = normalize(rand(1, truth.nmix));
truth.T = normalize(rand(truth.nmix, truth.nstates, truth.d), 2);
nsamples = 1000;
[X, y] = mixDiscreteSample(truth.T, truth.mixweight, nsamples); 


%[model, llhist] = mixModelFit(X, nmix, 'discrete', 'verbose', true);
[model, llhist] = mixDiscreteFit(X, nmix, 'verbose', true);

%Compare against the best permutation of the cluster labels.
%ypred = mixModelMapLatent(model, X);
pZ = mixDiscreteInferLatent(model, X);
[~, ypred] = max(pZ, [], 2);

allperms = perms(1:truth.nmix);
nperms = size(allperms, 1); 
errors = zeros(nperms, 1); 
for i=1:nperms
    errors(i) = sum(y ~= allperms(i, ypred)');
end
ypred = allperms(minidx(errors), ypred)';

nerrors = sum(y~=ypred)
