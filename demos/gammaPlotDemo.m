%% Plot a Gamma Distribution
%
%%
%as = [1 1.5 2  1 1.5 2]; bs = [1 1 1 1.5 1.5 1.5];

% This file is from pmtk3.googlecode.com

as = [1 1.5 2];
b = 1;
bs = b*ones(1,length(as));
figure;
[styles, colors, symbols] = plotColors;
legendStr = cell(1, length(as)); 
%styles = {'k:',  'b--', 'r-'};
for i=1:length(as)
    a = as(i); b = bs(i);
    xs = linspace(0.1, 7, 40);
    model.a = a; 
    model.b = b; 
    ps = exp(gammaLogprob(model, xs));
    style = [styles{i}, colors(i), symbols(i)];
    %plot(xs , ps, style, 'linewidth', 2.5, 'markersize', 10);
    plot(xs , ps, styles{i}, 'color', colors(i), 'linewidth', 3);
    hold on
    legendStr{i} = sprintf('a=%2.1f,b=%2.1f', a, b);
    axis tight; 
end
legend(legendStr, 'fontsize', 14);
title('Gamma distributions')
printPmtkFigure('gammaDistb1'); 

%%
as = [1];
b = 1;
bs = b*ones(1,length(as));
figure;
[styles, colors, symbols] = plotColors;
legendStr = cell(1, length(as)); 
%styles = {'k:',  'b--', 'r-'};
for i=1:length(as)
    a = as(i); b = bs(i);
    xs = linspace(0.1, 7, 40);
    model.a = a; 
    model.b = b; 
    ps = exp(gammaLogprob(model, xs));
    style = [styles{i}, colors(i), symbols(i)];
    %plot(xs , ps, style, 'linewidth', 2.5, 'markersize', 10);
    plot(xs , ps, styles{i}, 'color', colors(i), 'linewidth', 3);
    hold on
    legendStr{i} = sprintf('a=%2.1f,b=%2.1f', a, b);
    axis tight; 
end
printPmtkFigure('gammaDist1'); 
