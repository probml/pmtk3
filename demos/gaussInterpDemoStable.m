%% Interpolate some data using a joint Gaussian
% Based on p140 of "Introduction to Bayesian scientific computation"
% by Calvetti and Somersalo

% See also https://users.oden.utexas.edu/~tanbui/PublishedPapers/BayesianTutorial.pdf

function main()

demo(0.1)
demo(0.01)

end


function demo(priorVar)

setSeed(1);
n = 150;
m = 10;
Nobs = m;
D = n+1; % numnber of variables
Nhid = D-Nobs;
xs = linspace(0, 1, D);
perm = randperm(D);
obsNdx = perm(1:Nobs);
hidNdx = setdiff(1:D, obsNdx);


% Noisy observations of the x values at obsNdx
xobs = randn(Nobs, 1);
obsNoiseVar = 1;
y = xobs + sqrt(obsNoiseVar)*randn(Nobs, 1);

% Make a (n-1) * (n+1) tridiagonal matrix
L = 0.5*spdiags(ones(n-1,1) * [-1 2 -1], [0 1 2], n-1, n+1);

lambda = 1/priorVar; % precision
L = L*lambda;
L1 = L(:, hidNdx);
L2 = L(:, obsNdx);
B11 = L1'*L1;
B12 = L1'*L2;
B21 = B12';


%% Noise-free observations
% posterior on the Nhid hidden variables
postDist.mu = -inv(B11)*B12*xobs;
postDist.Sigma = inv(B11);
% posterior on all D variables
mu = zeros(D,1);
mu(hidNdx) = -inv(B11)*B12*xobs;
mu(obsNdx) = xobs;
Sigma = 1e-5*eye(D,D);
Sigma(hidNdx, hidNdx) = inv(B11);
postDist.mu = mu;
postDist.Sigma = Sigma;

str = sprintf('obsVar=0, priorVar=%3.2f', priorVar);
makePlots(postDist, xs, xobs, xobs, hidNdx, obsNdx, str);
fname = sprintf('gaussInterpNoisyDemoStable_obsVar%s_priorVar%s', ...
    int2str(round(100*0)), int2str(round(100*priorVar)));
disp(fname)
printPmtkFigure(fname)

%% Noisy observations
C = obsNoiseVar * eye(Nobs, Nobs);
GammaInv = [B11, B12;
        B21, B21 * inv(B11) * B12 + inv(C)];
Gamma = inv(GammaInv);   
postDist.Sigma = Gamma;
x  = [zeros(D-Nobs,1); y];
postDist.mu = Gamma * x;

str = sprintf('obsVar=%2.1f, priorVar=%3.2f', obsNoiseVar, priorVar);
makePlots(postDist, xs, xobs, y, hidNdx, obsNdx, str);
fname = sprintf('gaussInterpNoisyDemoStable_obsVar%s_priorVar%s', ...
    int2str(round(100*obsNoiseVar)), int2str(round(100*priorVar)));
disp(fname)
printPmtkFigure(fname)
end

function makePlots(postDist, xs, xobs, y, hidNdx, obsNdx, str)

D = length(hidNdx) + length(obsNdx);
mu = postDist.mu;
S2 = diag(postDist.Sigma);

% plot marginal posterior sd as gray band
figure; hold on;
f = [mu+2*sqrt(S2);flipdim(mu-2*sqrt(S2),1)];
fill([xs'; flipdim(xs',1)], f, [7 7 7]/8, 'EdgeColor', [7 7 7]/8);
plot(xs(obsNdx), y, 'bx', 'markersize', 14, 'linewidth', 3);
plot(xs, mu, 'r-', 'linewidth', 2);
title(str)
set(gca, 'ylim',[-5 5]);

% plot samples from posterior predictive
for i=1:3
  fs = gaussSample(postDist, 1);
  plot(xs, fs, 'k-', 'linewidth', 1)
end

end


