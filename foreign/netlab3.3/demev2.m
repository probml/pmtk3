%DEMEV2	Demonstrate Bayesian classification for the MLP.
%
%	Description
%	A synthetic two class two-dimensional dataset X is sampled  from a
%	mixture of four Gaussians.  Each class is associated with two of the
%	Gaussians so that the optimal decision boundary is non-linear. A 2-
%	layer network with logistic outputs is trained by minimizing the
%	cross-entropy error function with isotroipc Gaussian regularizer (one
%	hyperparameter for each of the four standard weight groups), using
%	the scaled conjugate gradient optimizer. The hyperparameter vectors
%	ALPHA and BETA are re-estimated using the function EVIDENCE. A graph
%	is plotted of the optimal, regularised, and unregularised decision
%	boundaries.  A further plot of the moderated versus unmoderated
%	contours is generated.
%
%	See also
%	EVIDENCE, MLP, SCG, DEMARD, DEMMLP2
%

%	Copyright (c) Ian T Nabney (1996-2001)


clc;

disp('This program demonstrates the use of the evidence procedure on')
disp('a two-class problem.  It also shows the improved generalisation')
disp('performance that can be achieved with moderated outputs; that is')
disp('predictions where an approximate integration over the true')
disp('posterior distribution is carried out.')
disp(' ')
disp('First we generate a synthetic dataset with two-dimensional input')
disp('sampled from a mixture of four Gaussians.  Each class is')
disp('associated with two of the Gaussians so that the optimal decision')
disp('boundary is non-linear.')
disp(' ')
disp('Press any key to see a plot of the data.')
pause;

% Generate the matrix of inputs x and targets t.

rand('state', 423);
randn('state', 423);

ClassSymbol1 = 'r.';
ClassSymbol2 = 'y.';
PointSize = 12;
titleSize = 10;

fh1 = figure;
set(fh1, 'Name', 'True Data Distribution');
whitebg(fh1, 'k');

% 
% Generate the data
% 
n=200;

% Set up mixture model: 2d data with four centres
% Class 1 is first two centres, class 2 from the other two
mix = gmm(2, 4, 'full');
mix.priors = [0.25 0.25 0.25 0.25];
mix.centres = [0 -0.1; 1.5 0; 1 1; 1 -1];
mix.covars(:,:,1) = [0.625 -0.2165; -0.2165 0.875];
mix.covars(:,:,2) = [0.25 0; 0 0.25];
mix.covars(:,:,3) = [0.2241 -0.1368; -0.1368 0.9759];
mix.covars(:,:,4) = [0.2375 0.1516; 0.1516 0.4125];

[data, label] = gmmsamp(mix, n);

% 
% Calculate some useful axis limits
% 
x0 = min(data(:,1));
x1 = max(data(:,1));
y0 = min(data(:,2));
y1 = max(data(:,2));
dx = x1-x0;
dy = y1-y0;
expand = 5/100;			% Add on 5 percent each way
x0 = x0 - dx*expand;
x1 = x1 + dx*expand;
y0 = y0 - dy*expand;
y1 = y1 + dy*expand;
resolution = 100;
step = dx/resolution;
xrange = [x0:step:x1];
yrange = [y0:step:y1];
% 					
% Generate the grid
% 
[X Y]=meshgrid([x0:step:x1],[y0:step:y1]);
% 
% Calculate the class conditional densities, the unconditional densities and
% the posterior probabilities
% 
px_j = gmmactiv(mix, [X(:) Y(:)]);
px = reshape(px_j*(mix.priors)',size(X));
post = gmmpost(mix, [X(:) Y(:)]);
p1_x = reshape(post(:, 1) + post(:, 2), size(X));
p2_x = reshape(post(:, 3) + post(:, 4), size(X));

plot(data((label<=2),1),data(label<=2,2),ClassSymbol1, 'MarkerSize', ...
PointSize)
hold on
axis([x0 x1 y0 y1])
plot(data((label>2),1),data(label>2,2),ClassSymbol2, 'MarkerSize', ...
    PointSize)

% Convert targets to 0-1 encoding
target=[label<=2];
disp(' ')
disp('Press any key to continue')
pause; clc;

disp('Next we create a two-layer MLP network with 6 hidden units and')
disp('one logistic output.  We use a separate inverse variance')
disp('hyperparameter for each group of weights (inputs, input bias,')
disp('outputs, output bias) and the weights are optimised with the')
disp('scaled conjugate gradient algorithm.  After each 100 iterations')
disp('the hyperparameters are re-estimated twice.  There are eight')
disp('cycles of the whole algorithm.')
disp(' ')
disp('Press any key to train the network and determine the hyperparameters.')
pause;

% Set up network parameters.
nin = 2;		% Number of inputs.
nhidden = 6;		% Number of hidden units.
nout = 1;		% Number of outputs.
alpha = 0.01;		% Initial prior hyperparameter.
aw1 = 0.01;
ab1 = 0.01;
aw2 = 0.01;
ab2 = 0.01;

% Create and initialize network weight vector.
prior = mlpprior(nin, nhidden, nout, aw1, ab1, aw2, ab2);
net = mlp(nin, nhidden, nout, 'logistic', prior);

% Set up vector of options for the optimiser.
nouter = 8;			% Number of outer loops.
ninner = 2;			% Number of innter loops.
options = foptions;		% Default options vector.
options(1) = 1;			% This provides display of error values.
options(2) = 1.0e-5;		% Absolute precision for weights.
options(3) = 1.0e-5;		% Precision for objective function.
options(14) = 100;		% Number of training cycles in inner loop. 

% Train using scaled conjugate gradients, re-estimating alpha and beta.
for k = 1:nouter
  net = netopt(net, options, data, target, 'scg');
  [net, gamma] = evidence(net, data, target, ninner);
  fprintf(1, '\nRe-estimation cycle %d:\n', k);
  disp(['  alpha = ', num2str(net.alpha')]);
  fprintf(1, '  gamma =  %8.5f\n\n', gamma);
  disp(' ')
  disp('Press any key to continue.')
  pause;
end

disp(' ')
disp('Network training and hyperparameter re-estimation are now complete.')
disp('Notice that the final error value is close to the number of data')
disp(['points (', num2str(n), ') divided by two.'])
disp('Also, the hyperparameter values differ, which suggests that a single')
disp('hyperparameter would not be so effective.')
disp(' ')
disp('First we train an MLP without Bayesian regularisation on the')
disp('same dataset using 400 iterations of scaled conjugate gradient')
disp(' ')
disp('Press any key to train the network by maximum likelihood.')
pause;
% Train standard network
net2 = mlp(nin, nhidden, nout, 'logistic');
options(14) = 400;
net2 = netopt(net2, options, data, target, 'scg');
y2g = mlpfwd(net2, [X(:), Y(:)]);
y2g = reshape(y2g(:, 1), size(X));

disp(' ')
disp('We can now plot the function represented by the trained networks.')
disp('We show the decision boundaries (output = 0.5) and the optimal')
disp('decision boundary given by applying Bayes'' theorem to the true')
disp('data model.')
disp(' ')
disp('Press any key to add the boundaries to the plot.')
pause;

% Evaluate predictions.
[yg, ymodg] = mlpevfwd(net, data, target, [X(:) Y(:)]);
yg = reshape(yg(:,1),size(X));
ymodg = reshape(ymodg(:,1),size(X));

% Bayesian decision boundary
[cB, hB] = contour(xrange,yrange,p1_x,[0.5 0.5],'b-');
[cNb, hNb] = contour(xrange,yrange,yg,[0.5 0.5],'r-');
[cN, hN] = contour(xrange,yrange,y2g,[0.5 0.5],'g-');
set(hB, 'LineWidth', 2);
set(hNb, 'LineWidth', 2);
set(hN, 'LineWidth', 2);
Chandles = [hB(1) hNb(1) hN(1)];
legend(Chandles, 'Bayes', ...
  'Reg. Network', 'Network', 3);

disp(' ')
disp('Note how the regularised network predictions are closer to the')
disp('optimal decision boundary, while the unregularised network is')
disp('overtrained.')

disp(' ')
disp('We will now compare moderated and unmoderated outputs for the');
disp('regularised network by showing the contour plot of the posterior')
disp('probability estimates.')
disp(' ')
disp('The first plot shows the regularised (moderated) predictions')
disp('and the second shows the standard predictions from the same network.')
disp('These agree at the level 0.5.')
disp('Press any key to continue')
pause
levels = 0:0.1:1;
fh4 = figure;
set(fh4, 'Name', 'Moderated outputs');
hold on
plot(data((label<=2),1),data(label<=2,2),'r.', 'MarkerSize', PointSize)
plot(data((label>2),1),data(label>2,2),'y.', 'MarkerSize', PointSize)

[cNby, hNby] = contour(xrange, yrange, ymodg, levels, 'k-');
set(hNby, 'LineWidth', 1);

fh5 = figure;
set(fh5, 'Name', 'Unmoderated outputs');
hold on
plot(data((label<=2),1),data(label<=2,2),'r.', 'MarkerSize', PointSize)
plot(data((label>2),1),data(label>2,2),'y.', 'MarkerSize', PointSize)

[cNbm, hNbm] = contour(xrange, yrange, yg, levels, 'k-');
set(hNbm, 'LineWidth', 1);

disp(' ')
disp('Note how the moderated contours are more widely spaced.  This shows')
disp('that there is a larger region where the outputs are close to 0.5')
disp('and a smaller region where the outputs are close to 0 or 1.')
disp(' ')
disp('Press any key to exit')
pause
close(fh1);
close(fh4);
close(fh5);