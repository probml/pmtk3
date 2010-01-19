%% Sequential Bayesian Updating of a Beta-Bernoulli model. 
% In this example we draw samples from a Bernoulli distribution and then
% sequentially fit a Beta-Bernoulli model, plotting the posterior of the
% parameters at each iteration. 

%% Sample
setSeed(0);
mu = 0.7; % 70% probability of success
n = 100;  % number of samples 
X = sum(rand(n, 1) < repmat(mu, n, 1), 2);
%% Update & Plot
figure; hold on;
[styles, colors, symbols] =  plotColors();
ns = [0 5 50 100];        
legendstr = cell(length(ns)+1,1);
betaPrior = [0.5, 0.5]; % uninformative prior
for i=1:length(ns)
    n = ns(i);
    Xsubset = X(1:n);
    nsucc = sum(Xsubset, 1);
    ntrials = size(Xsubset, 1);
    nfail = ntrials - nsucc;
    a = betaPrior(1) + nsucc;
    b = betaPrior(2) + nfail;
    xs = linspace(0, 1, 50); 
    logkerna = (a-1).*log(xs);       logkerna(a==1 & xs==0) = 0;
    logkernb = (b-1).*log(1-xs);     logkernb(b==1 & xs==1) = 0;
    p = exp(logkerna + logkernb - betaln(a,b));
    plotArgs = {'linewidth', 2};
    plot(colvec(xs), colvec(p), styles{i}, 'linewidth', 2);
    legendstr{i} = sprintf('n=%d', n);
end
box on;
xbar = mean(X);
pmax = 9.95;
h=line([xbar xbar], [-0.2 pmax]); 
set(h, 'linewidth', 3, 'Color', 'c');
legendstr{length(ns)+1} = 'truth';
legend(legendstr, 'Location', 'NorthWest');
axis([-0.01,1.01,-0.2,10])
printPmtkFigure betaSeqUpdate
