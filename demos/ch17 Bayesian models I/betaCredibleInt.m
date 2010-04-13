%% Compute beta credible interval
%Requires stats toolbox
%PMTKstats betainv
S = 47; 
N = 100; 
a = S+1; 
b = (N-S)+1; 
alpha = 0.05;
l  = betainv(alpha/2, a, b);
u  = betainv(1-alpha/2, a, b);
CI = [l,u] % 0.3749    0.5673


%% Monte Carlo approximation
setSeed(0);
S = 1000;
X = betarnd(a, b, S, 1);
X = sort(X);
Xl = X(round(S*alpha/2));
Xu = X(round(S*(1-alpha/2)));
CIhat = [Xl Xu]
CIhat2 = [quantile(X, alpha/2), quantile(X,1-alpha/2)]
