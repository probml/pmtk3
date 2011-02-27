%% Visually compare tanh and sigmoid functions
%
%%

% This file is from pmtk3.googlecode.com

xs = -10:0.1:10;
pt = tanh(xs);
ps = 1./(1+exp(-xs));
figure;
plot(xs, pt, 'r-', 'linewidth', 3)
hold on
plot(xs, ps, 'g:', 'linewidth', 3)
legend('tanh', 'sigmoid');
printPmtkFigure('tanhPlot')
