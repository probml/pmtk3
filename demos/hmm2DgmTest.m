%% Compare different inference methods for an HMM
%
%% Create a random hmm model

% This file is from pmtk3.googlecode.com

setSeed(0);
nstates = 250;
d = 10;
T = 100;
model = mkRndGaussHmm(nstates, d); 
%% Sample data
X = hmmSample(model, T, 1);
%% infer single marginals using fwdback
tic
[gamma, logpHmm] = hmmInferNodes(model, X);
t = toc;
fprintf('fwdbck: %g seconds\n', t);
%% infer single marginals using varelim
if 0
    tic;
    dgm        = hmmToDgm(model, T, 'infEngine', 'varelim');
    margVelim  = dgmInferNodes(dgm, 'localev', X);
    gammaVelim = tfMarg2Mat(margVelim);
    t = toc;
    fprintf('velim : %g seconds\n', t);
    assert(approxeq(gamma, gammaVelim));
end
%% Infer single marginals using jtree
if 1
    tic;
    dgm        = hmmToDgm(model, T, 'infEngine', 'jtree');
    [margJtree, logpDgm]  = dgmInferNodes(dgm, 'localev', X);
    gammaJtree = tfMarg2Mat(margJtree);
    t = toc;
    fprintf('jtree : %g seconds\n', t);
    assert(approxeq(gamma, gammaJtree));
end
%%
%% infer single marginals using libdai's Jtree code
if libdaiInstalled
    tic;
    dgm        = hmmToDgm(model, T, 'infEngine', 'libdaiJtree');
    margLD     = dgmInferNodes(dgm, 'localev', X);
    gammaLD = tfMarg2Mat(margLD);
    t = toc;
    fprintf('libdai: %g seconds\n', t);
    assert(approxeq(gamma, gammaLD));
end
%% Compare map assignments
mapDGM = dgmMap(dgm, 'localev', X); 
mapHMM = hmmMap(model, X); 
assert(isequal(mapDGM, mapHMM)); 












