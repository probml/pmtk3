%% Visually compare tanh and sigmoid functions
%
%%

% This file is from pmtk3.googlecode.com
[styles, colors, symbols, str] =  plotColors();
xs = -3:0.1:3;
names = {'tanh', 'sigmoid', 'ReLU', 'PReLU', 'ELU', 'softpplus'};
curves = {};
curves{end+1} = tanh(xs);
curves{end+1} = 1./(1+exp(-xs));
curves{end+1} = max(0, xs);
curves{end+1} = max(0, xs) + 0.1*min(0,xs);
curves{end+1} = xs .* (xs > 0)  + 0.1*(exp(xs)-1) .* (xs < 0);
curves{end+1} = log(1+exp(xs));
figure;
hold on
for i=1:numel(curves)
plot(xs, curves{i}, str{i}, 'linewidth', 3);
end
legend(names, 'location', 'northwest');
set(gca,'ylim',[-1 2]);
printPmtkFigure('tanhPlot')


[styles, colors, symbols, str] =  plotColors();
xs = -3:0.1:3;
names = {'tanh', 'sigmoid', 'ReLU'};
curves = {};
curves{end+1} = tanh(xs);
curves{end+1} = 1./(1+exp(-xs));
curves{end+1} = max(0, xs);
figure;
hold on
for i=1:numel(curves)
plot(xs, curves{i}, str{i}, 'linewidth', 3);
end
legend(names, 'location', 'northwest');
set(gca,'ylim',[-1 2]);
printPmtkFigure('reluPlot')
