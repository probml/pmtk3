function demopt1(xinit)
%DEMOPT1 Demonstrate different optimisers on Rosenbrock's function.
%
%	Description
%	The four general optimisers (quasi-Newton, conjugate gradients,
%	scaled conjugate gradients, and gradient descent) are applied to the
%	minimisation of Rosenbrock's well known `banana' function. Each
%	optimiser is run for at most 100 cycles, and a stopping criterion of
%	1.0e-4 is used for both position and function value. At the end, the
%	trajectory of each algorithm is shown on a contour plot of the
%	function.
%
%	DEMOPT1(XINIT) allows the user to specify a row vector with two
%	columns as the starting point.  The default is the point [-1 1]. Note
%	that the contour plot has an x range of [-1.5, 1.5] and a y range of
%	[-0.5, 2.1], so it is best to choose a starting point in the same
%	region.
%
%	See also
%	CONJGRAD, GRADDESC, QUASINEW, SCG, ROSEN, ROSEGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Initialise start point for search
if nargin < 1 | size(xinit) ~= [1 2]
  xinit = [-1 1];	% Traditional start point
end

% Find out if flops is available (i.e. pre-version 6 Matlab)
v = version;
if (str2num(strtok(v, '.')) >= 6)
    flops_works = logical(0);
else
    flops_works = logical(1);
end

% Set up options
options = foptions;	% Standard options
options(1) = -1; 	% Turn off printing completely
options(3) = 1e-8; 	% Tolerance in value of function
options(14) = 100;  	% Max. 100 iterations of algorithm

clc
disp('This demonstration compares the performance of four generic')
disp('optimisation routines when finding the minimum of Rosenbrock''s')
disp('function y = 100*(x2-x1^2)^2 + (1-x1)^2.')
disp(' ')
disp('The global minimum of this function is at [1 1].')
disp(['Each algorithm starts at the point [' num2str(xinit(1))...
	' ' num2str(xinit(2)) '].'])
disp(' ')
disp('Press any key to continue.')
pause 

% Generate a contour plot of the function
a = -1.5:.02:1.5;
b = -0.5:.02:2.1;
[A, B] = meshgrid(a, b);
Z = rosen([A(:), B(:)]);
Z = reshape(Z, length(b), length(a));
l = -1:6;
v = 2.^l;
fh1 = figure;
contour(a, b, Z, v)
title('Contour plot of Rosenbrock''s function')
hold on

clc
disp('We now use quasi-Newton, conjugate gradient, scaled conjugate')
disp('gradient, and gradient descent with line search algorithms')
disp('to find a local minimum of this function.  Each algorithm is stopped')
disp('when 100 cycles have elapsed, or if the change in function value')
disp('is less than 1.0e-8 or the change in the input vector is less than')
disp('1.0e-4 in magnitude.')
disp(' ')
disp('Press any key to continue.')
pause

clc
x = xinit;
flops(0)
[x, options, errlog, pointlog] = quasinew('rosen', x, options, 'rosegrad');
fprintf(1, 'For quasi-Newton method:\n')
fprintf(1, 'Final point is (%f, %f), value is %f\n', x(1), x(2), options(8))
fprintf(1, 'Number of function evaluations is %d\n', options(10))
fprintf(1, 'Number of gradient evaluations is %d\n', options(11))
if flops_works
    opt_flops = flops;
    fprintf(1, 'Number of floating point operations is %d\n', opt_flops)
end
fprintf(1, 'Number of cycles is %d\n', size(pointlog, 1) - 1);
disp(' ')

x = xinit;
flops(0)
[x, options, errlog2, pointlog2] = conjgrad('rosen', x, options, 'rosegrad');
fprintf(1, 'For conjugate gradient method:\n')
fprintf(1, 'Final point is (%f, %f), value is %f\n', x(1), x(2), options(8))
fprintf(1, 'Number of function evaluations is %d\n', options(10))
fprintf(1, 'Number of gradient evaluations is %d\n', options(11))
if flops_works
    opt_flops = flops;
    fprintf(1, 'Number of floating point operations is %d\n', ...
	opt_flops)
end
fprintf(1, 'Number of cycles is %d\n', size(pointlog2, 1) - 1);
disp(' ')

x = xinit;
flops(0)
[x, options, errlog3, pointlog3] = scg('rosen', x, options, 'rosegrad');
fprintf(1, 'For scaled conjugate gradient method:\n')
fprintf(1, 'Final point is (%f, %f), value is %f\n', x(1), x(2), options(8))
fprintf(1, 'Number of function evaluations is %d\n', options(10))
fprintf(1, 'Number of gradient evaluations is %d\n', options(11))
if flops_works
    opt_flops = flops;
    fprintf(1, 'Number of floating point operations is %d\n', opt_flops)
end
fprintf(1, 'Number of cycles is %d\n', size(pointlog3, 1) - 1);
disp(' ')

x = xinit;
options(7) = 1; % Line minimisation used
flops(0)
[x, options, errlog4, pointlog4] = graddesc('rosen', x, options, 'rosegrad');
fprintf(1, 'For gradient descent method:\n')
fprintf(1, 'Final point is (%f, %f), value is %f\n', x(1), x(2), options(8))
fprintf(1, 'Number of function evaluations is %d\n', options(10))
fprintf(1, 'Number of gradient evaluations is %d\n', options(11))
if flops_works
    opt_flops = flops;
    fprintf(1, 'Number of floating point operations is %d\n', opt_flops)
end
fprintf(1, 'Number of cycles is %d\n', size(pointlog4, 1) - 1);
disp(' ')
disp('Note that gradient descent does not reach a local minimum in')
disp('100 cycles.')
disp(' ')
disp('On this problem, where the function is cheap to evaluate, the')
disp('computational effort is dominated by the algorithm overhead.')
disp('However on more complex optimisation problems (such as those')
disp('involving neural networks), computational effort is dominated by')
disp('the number of function and gradient evaluations.  Counting these,')
disp('we can rank the algorithms: quasi-Newton (the best), conjugate')
disp('gradient, scaled conjugate gradient, gradient descent (the worst)')
disp(' ')
disp('Press any key to continue.')
pause
clc
disp('We now plot the trajectory of search points for each algorithm')
disp('superimposed on the contour plot.')
disp(' ')
disp('Press any key to continue.')
pause
plot(pointlog4(:,1), pointlog4(:,2), 'bd', 'MarkerSize', 6)
plot(pointlog3(:,1), pointlog3(:,2), 'mx', 'MarkerSize', 6, 'LineWidth', 2)
plot(pointlog(:,1), pointlog(:,2), 'k.', 'MarkerSize', 18)
plot(pointlog2(:,1), pointlog2(:,2), 'g+', 'MarkerSize', 6, 'LineWidth', 2)
lh = legend(  'Gradient Descent', 'Scaled Conjugate Gradients', ...
  'Quasi Newton', 'Conjugate Gradients');

hold off

clc
disp('Press any key to end.')
pause
close(fh1);
clear all;