%% Compare ppcaFit to Netlab's verson
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0);
n = 50;
d = 10;
X = rand(n,d);
K = 2;

model = ppcaFit(X, K);
[ll] = ppcaLogprob(model, X);

mix = gmm(d, 1, 'ppca', K);
opt = foptions; %#ok
mix = gmmem(mix, X, opt);
prob = gmmactiv(mix, X);

assert(approxeq(exp(ll), prob))


% Check syntatic correctness
X = ppcaSample(model, 10);
[postMean, postCov] = ppcaInferLatent(model, X);

