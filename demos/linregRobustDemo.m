
%% robust linear regression


seed = 0; setSeed(seed);
x = sort(rand(10,1));
y = 1+2*x + rand(size(x))-.5;
% add some outliers
x = [x' 0.1 0.5 0.9]';
k =  -5;
y = [y' k  k k]';

figure;
plot(x,y,'ko','linewidth',2)
title 'Linear data with noise and outliers'

[styles, colors, symbols] =  plotColors;
styles = {'r-o', 'b:s', 'g-.*', 'g-.+'};

n = length(x);
XX = [ones(n,1) x];
wLS = XX \ y; % least squares soln
hold on
xs = 0:0.1:1;
h = [];
h(1)=plot(xs,wLS(1) + wLS(2)*xs, styles{1},'linewidth',2, 'markersize', 10);

wLP = linregRobustLaplaceLinprog1dFit(x, y);
h(2) = plot(xs, wLP(1) + wLP(2)*xs, styles{2}, 'linewidth',2, 'markersize', 10);
legend(h, {'least squares', 'laplace'}, 'location', 'northwest')
set(gca,'ylim',[-6 4])
printPmtkFigure('linregRobust')

%% Huber loss

figure; hold on;
plot(x,y,'ko','linewidth',2)
h = [];
h(1) = plot(xs,wLS(1) + wLS(2)*xs, styles{1},'linewidth',2, 'markersize', 10);
legendStr = {'Least Squares'};

deltas = [1 5];
for i=1:length(deltas)
   delta = deltas(i);
   wHuber = linregRobustHuberFit(x, y, delta);
   str = sprintf('%s.-', colors(i+1));
   h(1+i) = plot(xs, wHuber(1) + wHuber(2)*xs, styles{i+1}, 'linewidth', 2, 'markersize', 10);
   legendStr{1+i} = sprintf('Huber loss %3.1f', delta);
end
legend(h, legendStr, 'location', 'east');
%axis_pct
set(gca,'ylim',[-6 4])
printPmtkFigure('linregRobustHuber')

