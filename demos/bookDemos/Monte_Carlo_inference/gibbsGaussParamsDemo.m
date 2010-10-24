function gibbsGaussParamsDemo()
% Gibbs sample mu and Sigma given complete observations of an MVN
% We use the reading comprehension dataset
% from Peter Hoff's book p113

% This file is from pmtk3.googlecode.com


%PMTKauthor Emtiyaz Khan
%PMTKneedsStatsToolbox iwishrnd

data = [59  77
43  39
34  46
32  26
42  38
38  43
55  68
67  86
64  77
45  60
49  50
72  59
34  38
70  48
34  55
50  58
41  54
52  60
60  75
34  47
28  48
35  33];

params.mean0 = [50 50]';
params.covMat0 = [625 312.5; 312.5 625];
params.nu0 = 4;
params.S0 = params.covMat0;

setSeed(0);
nSamples = 1000;
% data should be D*N
samples = gibbsSampler(data', params, nSamples);
burnin = 250;
samples.mu = samples.mu(:,burnin:end);
samples.Sigma = samples.Sigma(:,:,burnin:end);
Nsamples = size(samples.mu, 2);

% Plot posterior on mu
[p, grid1, grid2] = ksdensity2d(samples.mu');
figure;
contour(grid1, grid2, p);
hold on
ndx = 1:1:Nsamples;
plot(samples.mu(1,ndx), samples.mu(2,ndx), '.');
line([35 65], [35 65], 'color', 'r', 'linewidth', 3);
%set(gca, 'xlim', mu1range);
%set(gca, 'ylim', mu2range);
xlabel(sprintf('%s', '\mu_1'))
ylabel(sprintf('%s', '\mu_2'))
title('posterior on \mu')
printPmtkFigure('gibbsGaussParamsPostMu')

quantilePMTK( samples.mu(2,:) - samples.mu(1,:), [0.025 0.5 0.975])
mean(samples.mu(2,:) > samples.mu(1,:))


% Compute posterior predictive
Xpred = zeros(2,Nsamples);
for i=1:Nsamples
  x = gaussSample(samples.mu(:,i), samples.Sigma(:,:,i), 1);
  Xpred(:,i) = colvec(x);
end

% Now plot posterior predictive
[p, xgrid1, xgrid2] = ksdensity2d(Xpred');
figure;
contour(xgrid1, xgrid2, p)
hold on
plot(Xpred(1,:), Xpred(2,:), '.');
plot(data(:,1), data(:,2), 'x', 'color', 'r', ...
  'markersize', 8, 'linewidth', 2);
line([0 100], [0 100], 'color', 'r', 'linewidth', 3);
%set(gca, 'xlim', [0 100]);
%set(gca, 'ylim', [0 100]);
xlabel(sprintf('%s', 'x_1'))
ylabel(sprintf('%s', 'x_2'))
title('posterior predictive')
printPmtkFigure('gibbsGaussParamsPostPred')

end

function [samples] = gibbsSampler(data, params, nSamples)
% Sample mu and Sigma given a fully observed MVN
% samples.mu(:,s), samples.Sigma(:,:,s)
% We assume a factored Normal * IW prior
% See Peter Hoff's book sec 7.4
% 
% Written by Emtiyaz, CS, UBC 
% Modified on Jan 29, 2010


% hyperparameters
mean0 = params.mean0;
precMat0 = inv(params.covMat0);
nu0 = params.nu0;
S0 = params.S0;
[d,n] = size(data);

% Initialize chain by setting mu= sample mean
xbar = mean(data,2);
mu = xbar;
for i = 1:nSamples
  % sample Sigma given mu
  nu = nu0 + n;
  diff = data - repmat(mu,1,n);
  S = S0 + diff*diff';
  Sigma = iwishrnd(S,nu);
  
  % sample mu given Sigma
  precMat = inv(Sigma);
  covMat = inv(precMat0 + n*precMat);
  mean_ = covMat*(precMat0*mean0 + n*precMat*xbar);
  mu = mean_ + chol(covMat)*randn(d,1);
  
  % collect samples
  samples.mu(:,i) = mu;
  samples.Sigma(:,:,i) = Sigma;
end

end
