% Compare inference in an HMM and a tree - should be same!
% We use a Gaussian emission model
% This is similar to hmm2DgmTest

setSeed(0);
nstates = 3;
d = 2; %2dim observations
T = 5;
hmm = mkRndGaussHmm(nstates, d); 
X = hmmSample(hmm, T, 1);

[gamma, logpHmm] = hmmInferNodes(hmm, X);

tree  = hmmToTree(hmm, T);

[logZ, nodeBel] = treegmInferNodes(tree, X);

assert(approxeq(logZ, logpHmm))
assert(approxeq(nodeBel, gamma))
