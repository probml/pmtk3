%% Compute posterior sampling with integration

a = 1; b= 5;
l = 0.3; u = 0.7;
Pexact = betacdf(u,a,b) - betacdf(l,a,b)

setSeed(1);
X = betarnd(a,b,1,1000);
Pmc = mean(X <= u) - mean(X <= l)
