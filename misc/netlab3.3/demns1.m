%DEMNS1	Demonstrate Neuroscale for visualisation.
%
%	Description
%	This script demonstrates the use of the Neuroscale algorithm for
%	topographic projection and visualisation.  A data sample is generated
%	from a mixture of two Gaussians in 4d space, and an RBF is trained
%	with the stress error function to project the data into 2d.  The
%	training data and a test sample are both plotted in this projection.
%
%	See also
%	RBF, RBFTRAIN, RBFPRIOR
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Generate the data
% Fix seeds for reproducible results
rand('state', 420);
randn('state', 420);

input_dim = 4;
output_dim = 2;
mix = gmm(input_dim, 2, 'spherical');
mix.centres = [1 1 1 1; 0 0 0 0];
mix.priors = [0.5 0.5];
mix.covars = [0.1 0.1];

ndata = 60;
[data, labels] = gmmsamp(mix, ndata);

clc
disp('This demonstration illustrates the use of the Neuroscale model')
disp('to perform a topographic projection of data.  We begin by generating')
disp('60 data points from a mixture of two Gaussians in 4 dimensional space.')
disp(' ')
disp('Press any key to continue')
pause

ncentres = 10;
net = rbf(input_dim, ncentres, output_dim, 'tps', 'neuroscale');
dstring = ['the Sammon mapping.  The model has ', num2str(ncentres), ...
    ' centres, two outputs, and uses'];
clc
disp('The Neuroscale model is an RBF with a Stress error measure as used in')
disp(dstring)
disp('thin plate spline basis functions.')
disp(' ')
disp('It is trained using the shadow targets algorithm for at most 60 iterations.')
disp(' ')
disp('Press any key to continue')
pause

% First row controls shadow targets, second row controls rbfsetbf
options(1, :) = foptions;
options(2, :) = foptions;
options(1, 1) = 1;
options(1, 2) = 1e-2;
options(1, 3) = 1e-2;
options(1, 6) = 1;    % Switch on PCA initialisation
options(1, 14) = 60;
options(2, 1) = -1;   % Switch off all warnings
options(2, 5) = 1;
options(2, 14) = 10;
net2 = rbftrain(net, options, data);

disp(' ')
disp('After training the model, we project the training data by a normal')
disp('forward propagation through the RBF network.  Because there are two')
disp('outputs, the results can be plotted and visualised.')
disp(' ')
disp('Press any key to continue')
pause

% Plot the result
y = rbffwd(net2, data);
ClassSymbol1 = 'r.';
ClassSymbol2 = 'b.';
PointSize = 12;
fh1 = figure;
hold on;
plot(y((labels==1),1),y(labels==1,2),ClassSymbol1, 'MarkerSize', PointSize)
plot(y((labels>1),1),y(labels>1,2),ClassSymbol2, 'MarkerSize', PointSize)

disp(' ')
disp('In this plot, the red dots denote the first class and the blue')
disp('dots the second class.')
disp(' ')
disp('Press any key to continue.')
disp(' ')
pause

disp('We now generate a further 100 data points from the original distribution')
disp('and plot their projection using star symbols.  Note that a Sammon')
disp('mapping cannot be used to generalise to new data in this fashion.')

[test_data, test_labels] = gmmsamp(mix, 100);
ytest = rbffwd(net2, test_data);
ClassSymbol1 = 'ro';
ClassSymbol2 = 'bo';
% Circles are rather large symbols
PointSize = 6;
hold on
plot(ytest((test_labels==1),1),ytest(test_labels==1,2), ...
  ClassSymbol1, 'MarkerSize', PointSize)
plot(ytest((test_labels>1),1),ytest(test_labels>1,2),...
  ClassSymbol2, 'MarkerSize', PointSize)
hold on
legend('Class 1', 'Class 2', 'Test Class 1', 'Test Class 2')
disp('Press any key to exit.')
pause

close(fh1);
clear all;

