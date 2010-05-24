%% Integration via posterior sampling
%
%% Model parameters
a = 1;
b = 5;
l = 0.3;
u = 0.7;
%% Sample Mean
setSeed(1);
nsamples = [10, 100, 1000, 10000, 100000 1000000];
for i=1:numel(nsamples)
    X = betaSample(structure(a, b), [1, nsamples(i)]);
    Pmc = mean(X <= u) - mean(X <= l);
    fprintf('ns: %d, Pmc = %g\n', nsamples(i), Pmc); 
    %%
end
%% Exact
Pexact = betacdfPMTK(u, a, b) - betacdfPMTK(l, a, b);
fprintf('Exact: %g\n', Pexact); 