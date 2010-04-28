%DEMKNN1 Demonstrate nearest neighbour classifier.
%
%	Description
%	The problem consists of data in a two-dimensional space.  The data is
%	drawn from three spherical Gaussian distributions with priors 0.3,
%	0.5 and 0.2; centres (2, 3.5), (0, 0) and (0,2); and standard
%	deviations 0.2, 0.5 and 1.0. The first figure contains a scatter plot
%	of the data.  The data is the same as in DEMGMM1.
%
%	The second figure shows the data labelled with the corresponding
%	class given by the classifier.
%
%	See also
%	DEM2DDAT, DEMGMM1, KNN
%

%	Copyright (c) Ian T Nabney (1996-2001)

clc
disp('This program demonstrates the use of the K nearest neighbour algorithm.')
disp(' ')
disp('Press any key to continue.')
pause
% Generate the test data
ndata = 250;
randn('state', 42);
rand('state', 42);

[data, c] = dem2ddat(ndata);

% Randomise data order
data = data(randperm(ndata),:);

clc
disp('We generate the data in two-dimensional space from a mixture of')
disp('three spherical Gaussians. The centres are shown as black crosses')
disp('in the plot.')
disp(' ')
disp('Press any key to continue.')
pause
fh1 = figure;
plot(data(:, 1), data(:, 2), 'o')
set(gca, 'Box', 'on')
hold on
title('Data')
hp1 = plot(c(:, 1), c(:,2), 'k+')
% Increase size of crosses
set(hp1, 'MarkerSize', 8);
set(hp1, 'LineWidth', 2);
hold off

clc
disp('We next use the centres as training examplars for the K nearest')
disp('neighbour algorithm.')
disp(' ')
disp('Press any key to continue.')
pause

% Use centres as training data
train_labels = [1, 0, 0; 0, 1, 0; 0, 0, 1];

% Label the test data up to kmax neighbours
kmax = 1;
net = knn(2, 3, kmax, c, train_labels);
[y, l] = knnfwd(net, data);

clc
disp('We now plot each data point coloured according to its classification.')
disp(' ')
disp('Press any key to continue.')
pause
% Plot the result
fh2 = figure;
colors = ['b.'; 'r.'; 'g.'];
for i = 1:3
  thisX = data(l == i,1);
  thisY = data(l == i,2);
  hp(i) = plot(thisX, thisY, colors(i,:));
  set(hp(i), 'MarkerSize', 12);
  if i == 1
    hold on
  end
end
set(gca, 'Box', 'on');
legend('Class 1', 'Class 2', 'Class 3', 2)
hold on
labels = ['1', '2', '3'];
hp2 = plot(c(:, 1), c(:,2), 'k+');
% Increase size of crosses
set(hp2, 'MarkerSize', 8);
set(hp2, 'LineWidth', 2);

test_labels = labels(l(:,1));

title('Training data and data labels')
hold off

disp('The demonstration is now complete: press any key to exit.')
pause
close(fh1);
close(fh2);
clear all; 

