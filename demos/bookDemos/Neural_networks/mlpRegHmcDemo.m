%% Mulitlayer Perceptron HMC Regression Demo
% Based on Netlan's DEMHMC3
% We modified the code so the model is as similar as possible
% to the one in demev1, so we can compare MCMC with Laplace approx
%% Create the data and do EB on the network

% This file is from pmtk3.googlecode.com

mlpRegEvidenceDemo;


% use the EB hyper-params
alpha = net.alpha;
beta = net.beta;

% Create and initialize fresh network model.

% Initialise weights reasonably close to 0
net = mlp(nin, nhidden, nout, 'linear', alpha, beta);
net = mlpinit(net, 10);


% Set up vector of options for hybrid Monte Carlo.
nsamples = 100;		% Number of retained samples.

options = foptions;     % Default options vector.
options(1) = 1;		% Switch on diagnostics.
options(5) = 1;		% Use persistence
options(7) = 10;	% Number of steps in trajectory.
options(14) = nsamples;	% Number of Monte Carlo samples returned. 
options(15) = 300;	% Number of samples omitted at start of chain.
options(17) = 0.95;	% Alpha value in persistence
options(18) = 0.005;	% Step size.

w = mlppak(net);
% Initialise HMC
hmc('state', 42);
[samples, energies] = hmc('neterr', w, options, 'netgrad', net, x, t);


disp('The plot shows the underlying noise free function, the 100 samples')
disp('produced from the MLP, and their average as a Monte Carlo estimate')
disp('of the true posterior average.')
disp(' ')


nplot = 300;
plotvals = [0 : 1/(nplot - 1) : 1]';
pred = zeros(size(plotvals));
fh1 = figure;
hold on
for k = 1:nsamples
  w2 = samples(k,:);
  net2 = mlpunpak(net, w2);
  y = mlpfwd(net2, plotvals);
  % Sum predictions
  pred = pred + y;
  h4 = plot(plotvals, y, ':b', 'LineWidth', 1);
end
pred = pred./nsamples;

% Plot data
h1 = plot(x, t, 'ok', 'LineWidth', 2);
%axis([0 1 -3 3])
axis([0 1 -1.5 1.5])

% Plot function
[fx, fy] = fplot('sin(2*pi*x)', [0 1], '--g');
h2 = plot(fx, fy, '--g', 'LineWidth', 2);
set(gca, 'box', 'on');

% Plot averaged prediction
h3 = plot(plotvals, pred, '-r', 'LineWidth', 3);

lstrings = char('Data', 'Function', 'Prediction', 'Samples');
legend([h1 h2 h3 h4], lstrings, 3);
hold off

disp('Note how the predictions become much further from the true function')
disp('away from the region of high data density.')

printPmtkFigure('mlpRegHmc')
