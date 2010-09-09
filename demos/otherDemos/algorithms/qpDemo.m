%% Solve a simple quadratic program
%PMTKneedsOptimToolbox quadprog

% This file is from pmtk3.googlecode.com

requireOptimToolbox
H = 2*eye(2);
g = -[3,0.25];
A = [1 1; 1 -1; -1 1; -1 -1];
b = ones(4,1);
opts.LargeScale = 'off';
soln = quadprog(H, g, A, b, [], [], [], [], [], opts)
