%% Compare Gauss, and Laplacian distributions
%
%%

% This file is from pmtk3.googlecode.com

xs = -4:0.2:4;
v = 1;
mu = 0;

pr{1} = gaussProb(xs, mu, sqrt(v));

% variance of laplace = 2b^2
b = sqrt(v/2);
pr{2} = 1/(2*b)*exp(-abs(xs-mu)/b);

legendStr = {'Gauss', 'Laplace'};


%[styles, colors, symbols] =  plotColors;
styles = {'k:',  'b--', 'r-'};

figure; hold on
for i=1:2
  plot(xs, pr{i}, styles{i}, 'linewidth',3, 'markersize', 10);
end
legend(legendStr)
printPmtkFigure('laplacePdf')
title('prob. density functions')

figure; hold on
for i=1:2
  plot(xs, log(pr{i}), styles{i}, 'linewidth', 3, 'markersize', 10);
end
legend(legendStr)
printPmtkFigure('laplaceLogpdf')
title('log prob. density functions')


