%% Illustration of Newton's method for minimizing a 1d function
%
%%

% This file is from pmtk3.googlecode.com

function newtonsMethodMin1d


figure(); hold on;
xmin = 0.1;  xmax = 12;
ymin = -5; ymax = 4;
domain = xmin:0.01:xmax;
f = @(x) log(x) - 2;
Xk = 2;
m = 1/Xk;
b = f(Xk) - m*Xk;
tl = @(x) m*x+b;
plot([xmin, xmax], [0, 0], '-k', 'LineWidth', 2);
h1 = plot(domain, f(domain),  '-r' , 'LineWidth', 3);
h2 = plot(domain, tl(domain), '--b', 'LineWidth', 2.5);
legend([h1, h2], {'g(x)', 'g_{lin}(x)'}, 'Location', 'NorthWest');
plot(Xk, f(Xk), '.k', 'MarkerSize', 25);
plot(-b/m, 0, '.k', 'MarkerSize', 25);
plot([Xk,Xk], [ymin, f(Xk)], ':k');
plot([-b/m, -b/m], [ymin, 0], ':k');
% x^(k)
annotation(gcf,'textbox'        ,[0.2 0 0.09946 0.11],...
               'String'         ,{'x_{k}'},...
               'FontSize'       ,18,...
               'FitBoxToText'   ,'off',...
               'LineStyle'      ,'none');

% x^(k) + v^(k)
annotation(gcf,'textbox'        ,[0.345 0 0.09946 0.11],...
               'String'         ,{'x_{k}+d_{k}'},...
               'FontSize'       ,18,...
               'FitBoxToText'   ,'off',...
               'LineStyle'      ,'none');
axis([xmin, xmax, ymin, ymax]);
set(gca,'XTick', [Xk, -b/m], 'XTickLabel', {'', ''}, ...
    'YTick', 0, 'FontSize', 16, 'Box', 'on', 'LineWidth', 2);
printPmtkFigure('newtonsMethodMin1d');
end
