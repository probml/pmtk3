%% RosenBrock Demo
%
%%
%PMTKinteractive
%PMTKneedsOptimToolbox


% This file is from pmtk3.googlecode.com

% "A note on the extended rosenbrock function" Evol. Comp. 2006
% claims that for d=4 to 30 dims there are 2 local minima, at [1,1,...1] and
% and near [-1,1,...,1].
% Let us verify this for d=4 and d=5
%xstart = [-0.77565923 0.61309337 0.38206285 0.14597202]';
xstart = [-0.96205109 0.93573953 0.88071386 0.77787813 0.60509438]';
[f g H] = rosenbrock(xstart);
assert(isposdef(H))
norm(g)
% norm(g) : for d=4, 1e-7, for d=5: 1e-6
% norm(g) when x=[1 1 ... 1] is zero!
% 
% So the claim seems dubious...
%
%%

requireOptimToolbox
x = rand(10,1);
[f g H] = rosenbrock(x);
figure;spy(H)
title(sprintf('sparsity pattern of Hessian for extended Rosenbrock'))
  printPmtkFigure rosen10dSpy


% Now compare speed of using Hessian or approximating it

d = 20; % 200;
seed = 0;
setSeed(seed);
xstart = 2*rand(d,1)-1;
opts = optimset('display', 'off', 'DerivativeCheck', 'off');
[f g H] = rosenbrock(xstart);

clear options
options{1} = optimset(opts, 'GradObj', 'on', 'Hessian', 'on'); % analtyic Hessian
options{2} = optimset(opts, 'GradObj', 'on', 'Hessian', []); % dense numerical Hessian
options{3} = optimset(opts, 'GradObj', 'on', 'HessPattern', H); % sparse numerical Hessian
options{4} = optimset(opts, 'GradObj', [], 'HessPattern', H, 'LargeScale', 'off'); % numerical gradient and Hessian

clear t final
for i=1:length(options)
  tic
  [x fval exitflag output] = fminunc(@rosenbrock, xstart, options{i});
  t(i) = toc;
  final(i) = fval;
end

final
t
