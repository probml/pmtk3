%% Plot a Gaussian PDF and its CDF
%
%%
xs = -3:0.01:3;
mu = 0; sigma2 = 1;
p = gausspdf(xs', mu, sigma2);
figure; plot(xs, p, 'LineWidth', 2.5);
title('PDF');
printPmtkFigure gaussian1d
figure; plot(xs, cumsum(p), 'LineWidth',2.5);
title('CDF');
printPmtkFigure gaussianCDF