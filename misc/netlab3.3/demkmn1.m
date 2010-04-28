%DEMKMEAN Demonstrate simple clustering model trained with K-means.
%
%	Description
%	The problem consists of data in a two-dimensional space.  The data is
%	drawn from three spherical Gaussian distributions with priors 0.3,
%	0.5 and 0.2; centres (2, 3.5), (0, 0) and (0,2); and standard
%	deviations 0.2, 0.5 and 1.0. The first figure contains a scatter plot
%	of the data.  The data is the same as in DEMGMM1.
%
%	A cluster model with three components is trained using the batch K-
%	means algorithm. The matrix of centres is printed after training. The
%	second figure shows the data labelled with a colour derived from the
%	corresponding  cluster
%
%	See also
%	DEM2DDAT, DEMGMM1, KNN1, KMEANS
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Generate the data, fixing seeds for reproducible results
ndata = 250;
randn('state', 42);
rand('state', 42);
data = dem2ddat(ndata);

% Randomise data order
data = data(randperm(ndata),:);

clc 
disp('This demonstration illustrates the use of a cluster model to')
disp('find centres that reflect the distribution of data points.')
disp('We begin by generating the data from a mixture of three Gaussians')
disp('in two-dimensional space and plotting it.')
disp(' ')
disp('Press any key to continue.')
pause

fh1 = figure;
plot(data(:, 1), data(:, 2), 'o')
set(gca, 'Box', 'on')
title('Data')

% Set up cluster model
ncentres = 3;
centres = zeros(ncentres, 2);

% Set up vector of options for kmeans trainer
options = foptions;
options(1)  = 1;		% Prints out error values.
options(5) = 1;
options(14) = 10;		% Number of iterations.

clc
disp('The model is chosen to have three centres, which are initialised')
disp('at randomly selected data points.  We now train the model using')
disp('the batch K-means algorithm with a maximum of 10 iterations and')
disp('stopping tolerance of 1e-4.')
disp(' ')
disp('Press any key to continue.')
pause

% Train the centres from the data
[centres, options, post] = kmeans(centres, data, options);

% Print out model
disp(' ')
disp('Note that training has terminated before 10 iterations as there')
disp('has been no change in the centres or error function.')
disp(' ')
disp('The trained model has centres:')
disp(centres);
disp('Press any key to continue.')
pause

clc
disp('We now plot each data point coloured according to its classification')
disp('given by the nearest cluster centre.  The cluster centres are denoted')
disp('by black crosses.')

% 					Plot the result
fh2 = figure;

hold on
colours = ['b.'; 'r.'; 'g.'];

[tempi, tempj] = find(post);
hold on
for i = 1:3
  % Select data points closest to ith centre
  thisX = data(tempi(tempj == i), 1);
  thisY = data(tempi(tempj == i), 2);
  hp(i) = plot(thisX, thisY, colours(i,:));
  set(hp(i), 'MarkerSize', 12);
end
set(gca, 'Box', 'on')
legend('Class 1', 'Class 2', 'Class 3', 2)
hold on
plot(centres(:, 1), centres(:,2), 'k+', 'LineWidth', 2, ...
  'MarkerSize', 8)
title('Centres and data labels')
hold off

disp(' ')
disp('Press any key to end.')
pause

close(fh1);
close(fh2);
clear all;

