%% Demonstrate the effect of changing the hyper-parameters for an MLP
% based on demprior from netlab, but without the GUI code
%%

% This file is from pmtk3.googlecode.com

setSeed(1);

%{
% values from Bishop p260 - clearly not correct
aw1s = [1 1 1000 1000];
ab1s = [1 1 100 1000];
aw2s = [1 10 1 1];
ab2s = [1 1 1 1];
%}

% params(trial, param number)
% stnd of each weight/bias in each layer
params0 = [5 1 1 1];
params = repmat(params0, 5, 1);
sf = 5;
params(2,1) = params0(1)*sf;
params(3,2) = params0(2)*sf;
params(4,3) = params0(3)*sf;
params(5,4) = params0(4)*sf;

ntrials = 4;
for t=1:ntrials
  aw1 = 1/(params(t, 1)^2); ab1 = 1/(params(t,2)^2);
  aw2 = 1/(params(t,3)^2); ab2 = (1/params(t,4)^2);
 
  nhidden = 12;
  prior = mlpprior(1, nhidden, 1, aw1, ab1, aw2, ab2);
  xvals = -1:0.005:1;
  nsample = 10;    % Number of samples from prior.
  figure
  hold on
  axis([-1 1 -10 10]);  
  
  net = mlp(1, nhidden, 1, 'linear', prior);
  for i = 1:nsample
    net = mlpinit(net, prior);
    yvals = mlpfwd(net, xvals');
    plot(xvals', yvals, 'k', 'linewidth', 2);
  end
  ttl{t} = sprintf('%s=%5.3f, %s=%5.3f, %s=%5.3f, %s=%5.3f', ...
    '\sigma_1', 1/sqrt(aw1), '\tau_1', 1/sqrt(ab1), ...
    '\sigma_2', 1/sqrt(aw2), '\tau_2', 1/sqrt(ab2));
  title(ttl{t})
  printPmtkFigure(sprintf('mlpPriorsDemov2-%d', t))
end

