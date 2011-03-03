% Performance inference in an HMM and compare to inference on a tree
% We use a Gaussian emission model
% This is similar to hmm2DgmTest

setSeed(0);
nstates = 250;
d = 10;
T = 100;
model = mkRndGaussHmm(nstates, d); 
X = hmmSample(model, T, 1);

% Fwd-back
[gamma, logpHmm] = hmmInferNodes(model, X);

% Now set up equivalent tree
