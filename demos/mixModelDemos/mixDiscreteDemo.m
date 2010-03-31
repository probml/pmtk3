%% Simple test of MixDiscreteFitEM
%% Create Data
setSeed(1);
truth.nmix = 5;
truth.d = 4;
truth.nstates = 6;
truth.mixweight = [0.1 0.3 0.5 0.05 0.05];
truth.T = normalize(rand(truth.nstates, truth.d, truth.nmix), 1);
nsamples = 10000;
[X, y] = mixDiscreteSample(truth, nsamples); 
%% Fit
model = mixDiscreteFitEM(X, truth.nmix);
