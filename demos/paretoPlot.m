%% Plot the pareto distribution
%
%%

% This file is from pmtk3.googlecode.com

figure; hold on;
%ks = [3 2 1 1];
%ms = [1 1 1 0.001];

ks = [1 2 3 3];
ms = [0.001 0.001 0.001 0.1];
[styles, colors] = plotColors();
xs = 0.01:0.01:2;
nk = length(ks); 
legendStr = cell(1, nk); 
for i=1:nk
  model.K = ks(i);
  model.m = ms(i);
  p = exp(paretoLogprob(model, xs));
  plot(xs, p, styles{i}, 'color', colors(i), 'linewidth', 3);
  legendStr{i} = sprintf('m=%3.2f, k=%3.2f', ms(i), ks(i));
end
legend(legendStr)
title('Pareto distribution', 'fontsize', 15)
set(gca, 'xlim', [-0.01 0.5]);
set(gca, 'ylim', [-0.01 0.5])
printPmtkFigure pareto-pdf;


%% Plot on a log log scale
copyobj(gca, figure());
set(gca, 'xscale', 'log', 'yscale', 'log');
%figure;
%axis(exp([0 1.5 -6 2]));
%set(gca, 'XTick', 1:0.5:5);
%set(gca, 'YTick', [0 0.5 1 2 3]);
legend(legendStr, 'location', 'southwest')
title('Pareto(m,k) on log scale', 'fontsize', 15)
legend(legendStr)
printPmtkFigure pareto-log-pdf;


figure; hold on;
for i=1:nk
  model.K = ks(i);
  model.m = ms(i);
  logp = paretoLogprob(model, xs);
  plot(log(xs), logp, styles{i}, 'color', colors(i), 'linewidth', 3);
  legendStr{i} = sprintf('m=%3.2f, k=%3.2f', model.m, model.K);
end
legend(legendStr, 'location', 'southeast')
title('Log pdf of pareto distribution')
%set(gca, 'xlim', [1 5]);
%set(gca, 'ylim', [-0.1 2.1])
printPmtkFigure pareto-log-pdf2;

