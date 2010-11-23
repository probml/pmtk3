%% Compare the results of imputation on a MVN using three imputation methods: EM, ICM, and Gibbs
% PMTKauthor Cody Severinski
%%

% This file is from pmtk3.googlecode.com

setSeed(1);
d = 10; n = 100;
mu = randn(d,1); Sigma = randpd(d);

pcMissing = 0.2;
model = struct('mu', mu, 'Sigma', Sigma);
Xfull = gaussSample(model, n);
missing = rand(n,d) < pcMissing;

Xmiss = Xfull;
Xmiss(missing) = NaN;
Xhid = Xfull;
Xhid(~missing) = NaN;
verb = true;

% first EM
fprintf('EM First\n')
[model, LLtrace{1}] = gaussMissingFitEm(Xmiss, 'verbose', verb, 'maxIter', 500);
muHat{1} = model.mu;
SigmaHat{1} = model.Sigma; 

% second ICM
fprintf('Now ICM\n')
[model, LLtrace{2}] = gaussMissingFitICM(Xmiss, 'verbose', verb);
muHat{2} = model.mu;
SigmaHat{2} = model.Sigma; 
% third Gibbs
fprintf('Now Gibbs\n')
[model, dataSamples, LLtrace{3}] = gaussMissingFitGibbs(Xmiss, 'mu0', nanmeanPMTK(Xmiss), 'Lambda0', diag(nanvarPMTK(Xmiss)), 'k0', 0.01, 'dof', d + 2, 'verbose', verb);
muSamples = model.mu; SigmaSamples = model.Sigma; 
muHat{3} = mean(muSamples);
SigmaHat{3} = mean(SigmaSamples,3);

method = {'EM', 'ICM', 'Gibbs'};
% Print out some information
fprintf('True mean:\t\t %s\n', mat2str(rowvec(mu),2))
for m=1:length(method)
  fprintf('Mean for method %s:\t %s\n', method{m}, mat2str(rowvec(muHat{m}),2))
%  fprintf('Variance for method %s: %s\n', method{m}, mat2str(SigmaHat{m}))
end

plotOpts = {'b','g','r'};
% Plot the estimated means
figure(); subplot(3,3,1:3); hold on;
for m=1:length(method)
  plot(1:d, rowvec(muHat{m}), plotOpts{m})
end
xlabel('Dimension'); ylabel('Mean'); %legend(method, 'Location', 'Best');
title('Mean estimate for each method');

% Plot the difference in the means
subplot(3,3,4:6); hold on;
for m=1:length(method)
  plot(1:d, rowvec(muHat{m}) - rowvec(mu), plotOpts{m});
end
xlabel('Dimension'); ylabel('Difference in Mean');
title('Difference in mean estimate from truth');

% Plot the trace of log likelihood over iterations for all methods
a = zeros(3,4);
for m=1:length(method)
  subplot(3,3,6+m);
  h{m} = plot(LLtrace{m}, plotOpts{m});
  a(m,:) = axis;
  set(gca,'XTickLabel',num2str(get(gca,'XTick').'));
  set(gca,'YTickLabel',num2str(get(gca,'YTick').'))
end

% Adjust the axis -- does not improve visualization
%ymin = min(a(:,3)); ymax = max(a(:,4));
%a(:,3) = ymin; a(:,4) = ymax;
%for m=1:length(method)
%  subplot(3,3,6+m);
%  axis(a(m,:));
%end
%suplabel('Iteration', 'x', [.075 .1 .85 .85]); suplabel('Log likelihood', 'y', [.1 .075 .85 .85/3]);
%title('Log-likelihood trace over iterations');

% Place one overall legend
subplot(3,3,[1:3]);
L = legend(method);
set(L, 'position', [0.1, 0.02, 0.8, 0.03]);
set(L, 'fontsize', 8);
set(L, 'orientation', 'horizontal');
