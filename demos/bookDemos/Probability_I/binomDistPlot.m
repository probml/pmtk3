%% Plot Binomial Distributions as Histograms
%
%%

% This file is from pmtk3.googlecode.com

thetas = [1/2 1/4 3/4 0.9];
figure;
for i=1:4
    subplot(2,2,i)
    theta = thetas(i);
    N = 10;
    xs = 0:N;
    model.mu = theta;
    model.N = N;
    ps = exp(binomialLogprob(model, xs));
    bar(ps)
    set(gca,'xticklabel',xs)
    title(sprintf('theta=%5.3f',theta))
end
printPmtkFigure('binomDistPlot');
