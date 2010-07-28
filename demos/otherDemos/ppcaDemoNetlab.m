%% Compare ppcaFit to Netlab's verson
%
%%
setSeed(0);
n = 50;
d = 10;
X = rand(n,d);
K = 2;

%[W, Z, evals, Xrecon, mu] = pcaPmtk(X, K);
%[var, U, lambda] = ppca(X'*X/n, 1);

[W, mu, sigma2, evals, evecs] = ppcaFit(X, K);

mix = gmm(d, 1, 'ppca', K);
opt = foptions;
mix = gmmem(mix, X, opt);
prob = gmmactiv(mix, X);

[ll, logp] = ppcaLogprob(X, W, mu, sigma2, evals, evecs);

assert(approxeq(exp(ll), prob))
assert(approxeq(exp(logp), prob))

X = ppcaSample(10,  W, mu, sigma2, evals, evecs);

[postMean, postCov] = ppcaInfer(X, W, mu, sigma2, evals, evecs)


