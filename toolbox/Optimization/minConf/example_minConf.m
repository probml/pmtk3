% examples of calling the different minConf solvers to solve a bound
% constrained problems

clear all

% Set up Problem
nInst = 1000;
nVars = 100;
A = randn(nInst,nVars);
x = rand(nVars,1).*(rand(nVars,1) > .5);
b = A*x + randn;
funObj = @(x)SquaredError(x,A,b);

% Initial Value
x_init = zeros(nVars,1);

% Bounds
LB = zeros(nVars,1);
UB = inf(nVars,1);

%% Run the different methods

options = [];

fprintf('Two-Metric Projection w/ L-BFGS\n');
wTMP = minConf_TMP(funObj,x_init,LB,UB,options);
fprintf('**********\n');pause;

fprintf('Spectral Projected Gradient\n');
funProj = @(x)boundProject(x,LB,UB);
wSPG = minConf_SPG(funObj,x_init,funProj,options);
fprintf('**********\n');pause;

fprintf('Projected Quasi-Newton\n');
funProj = @(x)boundProject(x,LB,UB);
wPQN = minConf_PQN(funObj,x_init,funProj,options);
fprintf('**********\n');pause;

fprintf('Two-Metric Projection w/ Exact Hessian\n');
options.method = 'newton';
wNew = minConf_TMP(funObj,x_init,LB,UB,options);
fprintf('**********\n');pause;

fprintf('Solutions from different solvers:\n');
[wTMP wSPG wPQN wNew]