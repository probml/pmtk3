%DEMGLM2 Demonstrate simple classification using a generalized linear model.
%
%	Description
%	 The problem consists of a two dimensional input matrix DATA and a
%	vector of classifications T.  The data is  generated from three
%	Gaussian clusters, and a generalized linear model with softmax output
%	is trained using iterative reweighted least squares. A plot of the
%	data together with regions shaded by the classification given by the
%	network is generated.
%
%	See also
%	DEMGLM1, GLM, GLMTRAIN
%

%	Copyright (c) Ian T Nabney (1996-2001)


% Generate data from three classes in 2d
input_dim = 2;

% Fix seeds for reproducible results
randn('state', 42);
rand('state', 42);

ndata = 100;
% Generate mixture of three Gaussians in two dimensional space
mix = gmm(2, 3, 'spherical');
mix.priors = [0.4 0.3 0.3];            % Cluster priors
mix.centres = [2, 2; 0.0, 0.0; 1, -1];  % Cluster centres
mix.covars = [0.5 1.0 0.6];

[data, label] = gmmsamp(mix, ndata);
id = eye(3);
targets = id(label,:);

% Plot the result

clc
disp('This demonstration illustrates the use of a generalized linear model')
disp('to classify data from three classes in a two-dimensional space. We')
disp('begin by generating and plotting the data.')
disp(' ')
disp('Press any key to continue.')
pause

fh1 = figure;
plot(data(label==1,1), data(label==1,2), 'bo');
hold on
axis([-4 5 -4 5]);
set(gca, 'Box', 'on')
plot(data(label==2,1), data(label==2,2), 'rx')
plot(data(label==3, 1), data(label==3, 2), 'go')
title('Data')

clc
disp('Now we fit a model consisting of a softmax function of')
disp('a linear combination of the input variables.')
disp(' ')
disp('The model is trained using the IRLS algorithm for up to 10 iterations')
disp(' ')
disp('Press any key to continue.')
pause

net = glm(input_dim, size(targets, 2), 'softmax');
options = foptions;
options(1) = 1;
options(14) = 10;
net = glmtrain(net, options, data, targets);

disp(' ')
disp('We now plot the decision regions given by this model.')
disp(' ')
disp('Press any key to continue.')
pause

x = -4.0:0.2:5.0;
y = -4.0:0.2:5.0;
[X, Y] = meshgrid(x,y);
X = X(:);
Y = Y(:);
grid = [X Y];
Z = glmfwd(net, grid);
[foo , class] = max(Z');
class = class';
colors = ['b.'; 'r.'; 'g.'];
for i = 1:3
  thisX = X(class == i);
  thisY = Y(class == i);
  h = plot(thisX, thisY, colors(i,:));
  set(h, 'MarkerSize', 8);
end
title('Plot of Decision regions')

hold off

clc
disp('Note that the boundaries of decision regions are straight lines.')
disp(' ')
disp('Press any key to end.')
pause
close(fh1);
clear all; 

