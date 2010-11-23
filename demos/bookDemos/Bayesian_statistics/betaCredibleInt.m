%% Compute beta credible interval
%
%%

% This file is from pmtk3.googlecode.com

S = 47; 
N = 100; 
a = S+1; 
b = (N-S)+1; 
alpha = 0.05;
l  = betainvPMTK(alpha/2, a, b);
u  = betainvPMTK(1-alpha/2, a, b);
CI = [l, u] % 0.3749    0.5673
%% Monte Carlo approximation
setSeed(0);
S = 1000;
model = structure(a, b); 
X = betaSample(model, S);
X = sort(X);
Xl = X(round(S*alpha/2));
Xu = X(round(S*(1-alpha/2)));
CIhat = [Xl Xu]
CIhat2 = [quantilePMTK(X, alpha/2), quantilePMTK(X, 1-alpha/2)];
