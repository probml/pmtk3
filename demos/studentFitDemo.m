%% Compare EM to matlab stats toolbox
% PMTKneedsStatsToolbox mle
%%

% This file is from pmtk3.googlecode.com

requireStatsToolbox
%% same data as gaussVsStudentOutlierDemo
n = 30;
setSeed(8);
data = randn(n,1);
outliers = [8 ; 8.75 ; 9.5];
X = [data; outliers];
MLEs = mle(X,'distribution','tlocationscale');
mu1d = MLEs(1); sigma1d = MLEs(2); dof1d = MLEs(3);

opts.dof =[];
%opts.dof = dof1d;
opts.useSpeedup =false; % seems to have no affect
opts.verbose = false;

opts.useECME = false;
[model, niter1d] = studentFitEm(X, opts);
muHat1d = model.mu; SigmaHat1d = model.Sigma; dofHat1d = model.dof;

opts.useECME = true;
[model, niter1dECME] = studentFitEm(X, opts);
muHat1dECME = model.mu; SigmaHat1dECME = model.Sigma; dofHat1dECME = model.dof;

fprintf('dof  : matlab %5.3f, em %5.3f, ecme %5.3f\n', ...
  dof1d, dofHat1d, dofHat1dECME);
fprintf('mu   : matlab %5.3f, em %5.3f, ecme %5.3f\n', ...
  mu1d, muHat1d, muHat1dECME);
fprintf('sigma: matlab %5.3f, em %5.3f, ecme %5.3f\n', ...
  sigma1d, sqrt(SigmaHat1d), sqrt(SigmaHat1dECME));
