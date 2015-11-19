%% Visually compare tanh and sigmoid functions
%
%%

% This file is from pmtk3.googlecode.com

xs = -3:0.1:3;
pt = tanh(xs);
ps = 1./(1+exp(-xs));
pr = max(0, xs);
figure;
plot(xs, pt, 'r-', 'linewidth', 3)
hold on
plot(xs, ps, 'g:', 'linewidth', 3)
plot(xs, pr, 'k-.', 'linewidth', 3);
legend('tanh', 'sigmoid', 'relu');
printPmtkFigure('tanhPlot')
