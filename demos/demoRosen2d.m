%% Rosenbrock 2D demo
%PMTKneedsOptimToolbox fminunc
%%

% This file is from pmtk3.googlecode.com

requireOptimToolbox;
xstart = [-1 2];

% basic usage with anonymous function and numerical derivatives
[x fval exitflag output] = fminunc(@(X) (1-X(1))^2 + 100*(X(2)-X(1)^2)^2, xstart)

% now specify gradient and Hessian analytically
opts = optimset('fminunc');
opts = optimset(opts, 'GradObj', 'on', 'Hessian', 'on');
[x fval exitflag output] = fminunc(@rosen2d, xstart, opts)

% now plot function values on top of contour plot
[xc,yc] = meshgrid(-2:.05:2);
zc = reshape(rosen2d([xc(:),yc(:)]), size(xc));
figure;
contour(xc,yc,zc,[.1 1 4 16 64 256 1024 4096])
hold on
opts = optimset(opts, 'OutputFcn', @optimplot2d, 'Display', 'iter');
[x fval] = fminunc(@rosen2d, xstart, opts)
