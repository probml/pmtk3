%% Plot the sigmoid function
%
%%

% This file is from pmtk3.googlecode.com

xs = -10:0.1:10;
p = 1./(1+exp(-xs));
figure;
plot(xs, p, '-', 'linewidth', 3)
printPmtkFigure('sigmoidPlot')
