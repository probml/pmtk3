% compare EM to  matlab stats toolbox
% The results are quite different... Is this a bug?

if ~statsToolboxInstalled
  error('requires stats toolbox')
end

setSeed(1);

% same data as gaussVsStudentOutlierDemo
n = 30;
seed = 8; randn('state',seed);
data = randn(n,1);
outliers = [8 ; 8.75 ; 9.5];
X = [data; outliers];
MLEs = mle(X,'distribution','tlocationscale')
mu1d = MLEs(1); sigma1d = MLEs(2); dof1d = MLEs(3);

dof =[];
%dof = dof1d;
useECME = true; useSpeedup =false; verbose = true;
[model, niter1d] = studentFitEm(X, dof,  useECME, useSpeedup, verbose);
muHat1d = model.mu; SigmaHat1d = model.Sigma; dofHat1d = model.dof;
fprintf('dof: matlab %3.2f, em %3.2f\n', dof1d, dofHat1d);
fprintf('mu: matlab %3.2f, em %3.2f\n', mu1d, muHat1d);
fprintf('sigma: matlab %3.2f, em %3.2f\n', sigma1d, sqrt(SigmaHat1d));
