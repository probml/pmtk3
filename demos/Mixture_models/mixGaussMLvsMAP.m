%% Demonstrate failure of MLE for GMMs in high-D case, whereas MAP works
%PMKTauthor Hannes Bretschneider
%PMTKslow

%% Create data

N = 100;
K = 3;
dims = 10:20:100;
warning('off', 'MATLAB:nearlySingularMatrix')
for dimi = 1:length(dims)
  D = dims(dimi);
  seeds = 1:3;
  NmleFail(dimi) = 0; NmapFail(dimi) = 0;
  Sigma = zeros(D,D,K); 

for seedi=1:length(seeds)
  setSeed(seeds(seedi));

%RandStream.setDefaultStream(RandStream('mt19937ar','seed',0));
mu = [-1 1 zeros(1,D-2); 1 -1 zeros(1,D-2); 3 -1 zeros(1,D-2)]';
Sigma(:,:,1) = [1 -.7 zeros(1,D-2); -.7 1 zeros(1,D-2);...
    zeros(D-2,2) eye(D-2)];
Sigma(:,:,2) = [1 .7 zeros(1,D-2); .7 1 zeros(1,D-2);...
    zeros(D-2,2) eye(D-2)];
Sigma(:,:,3) = [1 .9 zeros(1,D-2); .9 1 zeros(1,D-2);...
    zeros(D-2,2) eye(D-2)];
X = NaN(N, D, K);
for c=1:K
    R = chol(Sigma(:,:,c));
    X(:,:,c) = repmat(mu(:,c)', N, 1) + randn(N, D) * R;
end
X = [X(:,:,1); X(:,:,2)];
mu0 = rand(D,K);
mixweight = normalize(ones(K,1));


%% Fit 

try
  [modelGMM, loglikHistGMM] = mixGaussFitEm(X, K,...
    'mu', mu0, 'Sigma', Sigma, 'mixweight', mixweight, 'doMAP', 0);
catch
  fprintf('MLE failed\n'); NmleFail(dimi) = NmleFail(dimi) + 1;
end

try
  [modelGMMMAP, loglikHistGMMMAP] = mixGaussFitEm(X, K, ...
    'mu', mu0, 'Sigma', Sigma, 'mixweight', mixweight,  'doMAP', 1, 'verbose', false);
catch
  fprintf('MAP failed\n'); NmapFail(dimi) = NmapFail(dimi) + 1;
end


end

ntrials = length(seeds);
fprintf('Out of %d trials (with N=%d, D=%d), MLE failed %d times, MAP failed %d times\n', ...
  ntrials, N, D, NmleFail(dimi), NmapFail(dimi))


end

%% Plot
figure; hold on
plot(dims, NmleFail/ntrials, 'r-o', 'linewidth', 2);
plot(dims, NmapFail/ntrials, 'k:s', 'linewidth', 2);
legend('MLE', 'MAP', 'location', 'east')
title('fraction of times EM for GMM fails vs dimensionality')
axis_pct
printPmtkFigure('mixGaussMLvsMAP')

warning('on', 'MATLAB:nearlySingularMatrix')
