%% Peaks Demo
%PMTKneedsOptimToolbox fminunc
%%
%[X,Y,Z] = peaks; % 49x49 surface surface

% This file is from pmtk3.googlecode.com


requireOptimToolbox;
[X,Y] = meshgrid(linspace(-2.5,2.5,40),linspace(-3,3,50));
Z = peaks(X,Y);

figure;
%surf(X,Y,Z);
contour(X,Y,Z); colorbar
xlabel('x'); ylabel('y');
%view(-19,48)
hold on

opts = optimset('fminsearch');
%opts.OutputFcn = @optimplot;
opts.Display = 'iter';
opts.LargeScale = 'off';
[Xfinal, fval, exitFlag, output] = fminsearch(@(x) peaks(x(1),x(2)), [0 0], opts);
title('fminsearch')

figure;
%surf(X,Y,Z);
contour(X,Y,Z); colorbar
xlabel('x'); ylabel('y');
%view(-19,48)
hold on

opts = optimset('fminunc');
opts.LargeScale = 'off';
%opts.OutputFcn = @optimplot;
opts.Display = 'iter';
Xfinal = fminunc(@(x) peaks(x(1),x(2)), [0 0], opts);
title('fminunc')
