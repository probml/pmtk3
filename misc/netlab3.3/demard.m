%DEMARD	Automatic relevance determination using the MLP.
%
%	Description
%	This script demonstrates the technique of automatic relevance
%	determination (ARD) using a synthetic problem having three input
%	variables: X1 is sampled uniformly from the range (0,1) and has a low
%	level of added Gaussian noise, X2 is a copy of X1 with a higher level
%	of added noise, and X3 is sampled randomly from a Gaussian
%	distribution. The single target variable is determined by
%	SIN(2*PI*X1) with additive Gaussian noise. Thus X1 is very relevant
%	for determining the target value, X2 is of some relevance, while X3
%	is irrelevant. The prior over weights is given by the ARD Gaussian
%	prior with a separate hyper-parameter for the group of weights
%	associated with each input. A multi-layer perceptron is trained on
%	this data, with re-estimation of the hyper-parameters using EVIDENCE.
%	The final values for the hyper-parameters reflect the relative
%	importance of the three inputs.
%
%	See also
%	DEMMLP1, DEMEV1, MLP, EVIDENCE
%

%	Copyright (c) Ian T Nabney (1996-2001)

clc;
disp('This demonstration illustrates the technique of automatic relevance')
disp('determination (ARD) using a multi-layer perceptron.')
disp(' ');
disp('First, we set up a synthetic data set involving three input variables:')
disp('x1 is sampled uniformly from the range (0,1) and has a low level of')
disp('added Gaussian noise, x2 is a copy of x1 with a higher level of added')
disp('noise, and x3 is sampled randomly from a Gaussian distribution. The')
disp('single target variable is given by t = sin(2*pi*x1) with additive')
disp('Gaussian noise. Thus x1 is very relevant for determining the target')
disp('value, x2 is of some relevance, while x3 should in principle be')
disp('irrelevant.')
disp(' ');
disp('Press any key to see a plot of t against x1.')
pause;

% Generate the data set.
randn('state', 0); 
rand('state', 0); 
ndata = 100;
noise = 0.05;
x1 = rand(ndata, 1) + 0.002*randn(ndata, 1);
x2 = x1 + 0.02*randn(ndata, 1);
x3 = 0.5 + 0.2*randn(ndata, 1);
x = [x1, x2, x3];
t = sin(2*pi*x1) + noise*randn(ndata, 1);

% Plot the data and the original function.
h = figure;
plotvals = linspace(0, 1, 200)';
plot(x1, t, 'ob')
hold on
axis([0 1 -1.5 1.5])
[fx, fy] = fplot('sin(2*pi*x)', [0 1]);
plot(fx, fy, '-g', 'LineWidth', 2);
legend('data', 'function');

disp(' ');
disp('Press any key to continue')
pause; clc;

disp('The prior over weights is given by the ARD Gaussian prior with a')
disp('separate hyper-parameter for the group of weights associated with each')
disp('input. This prior is set up using the utility MLPPRIOR. The network is')
disp('trained by error minimization using scaled conjugate gradient function')
disp('SCG. There are two cycles of training, and at the end of each cycle')
disp('the hyper-parameters are re-estimated using EVIDENCE.')
disp(' ');
disp('Press any key to create and train the network.')
disp(' ');
pause;

% Set up network parameters.
nin = 3;			% Number of inputs.
nhidden = 2;			% Number of hidden units.
nout = 1;			% Number of outputs.
aw1 = 0.01*ones(1, nin);	% First-layer ARD hyperparameters.
ab1 = 0.01;			% Hyperparameter for hidden unit biases.
aw2 = 0.01;			% Hyperparameter for second-layer weights.
ab2 = 0.01;			% Hyperparameter for output unit biases.
beta = 50.0;			% Coefficient of data error.

% Create and initialize network.
prior = mlpprior(nin, nhidden, nout, aw1, ab1, aw2, ab2);
net = mlp(nin, nhidden, nout, 'linear', prior, beta);

% Set up vector of options for the optimiser.
nouter = 2;			% Number of outer loops
ninner = 10;		        % Number of inner loops
options = zeros(1,18);		% Default options vector.
options(1) = 1;			% This provides display of error values.
options(2) = 1.0e-7;	% This ensures that convergence must occur
options(3) = 1.0e-7;
options(14) = 300;		% Number of training cycles in inner loop. 

% Train using scaled conjugate gradients, re-estimating alpha and beta.
for k = 1:nouter
  net = netopt(net, options, x, t, 'scg');
  [net, gamma] = evidence(net, x, t, ninner);
  fprintf(1, '\n\nRe-estimation cycle %d:\n', k);
  disp('The first three alphas are the hyperparameters for the corresponding');
  disp('input to hidden unit weights.  The remainder are the hyperparameters');
  disp('for the hidden unit biases, second layer weights and output unit')
  disp('biases, respectively.')
  fprintf(1, '  alpha =  %8.5f\n', net.alpha);
  fprintf(1, '  beta  =  %8.5f\n', net.beta);
  fprintf(1, '  gamma =  %8.5f\n\n', gamma);
  disp(' ')
  disp('Press any key to continue.')
  pause
end

% Plot the function corresponding to the trained network.
figure(h); hold on;
[y, z] = mlpfwd(net, plotvals*ones(1,3));
plot(plotvals, y, '-r', 'LineWidth', 2)
legend('data', 'function', 'network');

disp('Press any key to continue.');
pause; clc;

disp('We can now read off the hyperparameter values corresponding to the')
disp('three inputs x1, x2 and x3:')
disp(' ');
fprintf(1, '    alpha1: %8.5f\n', net.alpha(1));
fprintf(1, '    alpha2: %8.5f\n', net.alpha(2));
fprintf(1, '    alpha3: %8.5f\n', net.alpha(3));
disp(' ');
disp('Since each alpha corresponds to an inverse variance, we see that the')
disp('posterior variance for weights associated with input x1 is large, that')
disp('of x2 has an intermediate value and the variance of weights associated')
disp('with x3 is small.')
disp(' ')
disp('Press any key to continue.')
disp(' ')
pause
disp('This is confirmed by looking at the corresponding weight values:')
disp(' ');
fprintf(1, '    %8.5f    %8.5f\n', net.w1');
disp(' ');
disp('where the three rows correspond to weights asssociated with x1, x2 and')
disp('x3 respectively. We see that the network is giving greatest emphasis')
disp('to x1 and least emphasis to x3, with intermediate emphasis on')
disp('x2. Since the target t is statistically independent of x3 we might')
disp('expect the weights associated with this input would go to')
disp('zero. However, for any finite data set there may be some chance')
disp('correlation between x3 and t, and so the corresponding alpha remains')
disp('finite.')

disp(' ');
disp('Press any key to end.')
pause; clc; close(h); clear all

