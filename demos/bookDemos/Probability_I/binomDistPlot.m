%% Plot Binomial Distributions as Histograms
%
%%

% This file is from pmtk3.googlecode.com

thetas = [1/4 1/2 3/4 0.9];
for i=1:4
    figure; %subplot(2,2,i)
    theta = thetas(i);
    N = 10;
    xs = 0:N;
    model.mu = theta;
    model.N = N;
    ps = exp(binomialLogprob(model, xs));
    bar(ps)
    set(gca,'xticklabel',xs)
    title(sprintf('%s=%5.3f','\theta',theta))
    printPmtkFigure(sprintf('binomDistPlot%d',i));
end

