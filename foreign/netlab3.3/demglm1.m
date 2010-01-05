%DEMGLM1 Demonstrate simple classification using a generalized linear model.
%
%	Description
%	 The problem consists of a two dimensional input matrix DATA and a
%	vector of classifications T.  The data is  generated from two
%	Gaussian clusters, and a generalized linear model with logistic
%	output is trained using iterative reweighted least squares. A plot of
%	the data together with the 0.1, 0.5 and 0.9 contour lines of the
%	conditional probability is generated.
%
%	See also
%	DEMGLM2, GLM, GLMTRAIN
%

%	Copyright (c) Ian T Nabney (1996-2001)


% Generate data from two classes in 2d
input_dim = 2;

% Fix seeds for reproducible results
randn('state', 42);
rand('state', 42);

ndata = 100;
% Generate mixture of two Gaussians in two dimensional space
mix = gmm(2, 2, 'spherical');
mix.priors = [0.4 0.6];              % Cluster priors 
mix.centres = [2.0, 2.0; 0.0, 0.0];  % Cluster centres
mix.covars = [0.5, 1.0];

[data, label] = gmmsamp(mix, ndata);
targets = label - ones(ndata, 1);

% Plot the result

clc
disp('This demonstration illustrates the use of a generalized linear model')
disp('to classify data from two classes in a two-dimensional space. We')
disp('begin by generating and plotting the data.')
disp(' ')
disp('Press any key to continue.')
pause

fh1 = figure;
plot(data(label==1,1), data(label==1,2), 'bo');
hold on
axis([-4 5 -4 5])
set(gca, 'box', 'on')
plot(data(label==2,1), data(label==2,2), 'rx')
title('Data')

clc
disp('Now we fit a model consisting of a logistic sigmoid function of')
disp('a linear combination of the input variables.')
disp(' ')
disp('The model is trained using the IRLS algorithm for 5 iterations')
disp(' ')
disp('Press any key to continue.')
pause

net = glm(input_dim, 1, 'logistic');
options = foptions;
options(1) = 1;
options(14) = 5;
net = glmtrain(net, options, data, targets);

disp(' ')
disp('We now plot some density contours given by this model.')
disp('The contour labelled 0.5 is the decision boundary.')
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
Z = reshape(Z, length(x), length(y));
v = [0.1 0.5 0.9];
[c, h] = contour(x, y, Z, v);
title('Generalized Linear Model')
set(h, 'linewidth', 3)
clabel(c, h);

clc
disp('Note that the contours of constant density are straight lines.')
disp(' ')
disp('Press any key to end.')
pause
close(fh1);
clear all;

