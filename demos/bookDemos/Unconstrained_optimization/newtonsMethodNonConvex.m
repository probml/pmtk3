%% Illustration of Newton's method for a non convex function. 
%
%%

% This file is from pmtk3.googlecode.com

function newtonsMethodNonConvex


figure(); hold on; 
xmin   = -4;  xmax = 13;
ymin   = -50; ymax = 600;
domain = xmin:0.01:xmax;
f = @(x)-x.^3 + 15*x.^2;
Xk = 8;         
f1 = @(x) -3*x.^2 + 30*x;
f2 = @(x) -6*x + 30;
t = @(x) f(Xk) + f1(Xk)*(x - Xk) + (1/2)*f2(Xk)*(x - Xk).^2;
[val, maxNDX] = max(t(domain));
maximum = domain(maxNDX);
h1 = plot(domain, f(domain), '-r', 'LineWidth', 3);
h2 = plot(domain, t(domain), '--b', 'LineWidth', 2.5);
legend([h1, h2], {'f(x)', 'f_{quad}(x)'}, 'Location', 'NorthWest');
plot(Xk, f(Xk), '.k', 'MarkerSize', 25);
plot([Xk, Xk], [ymin, f(Xk)], ':k');
plot(maximum, t(maximum),'.k', 'MarkerSize', 25);
plot([maximum,  maximum], [ymin, t(maximum)], ':k');
% x^(k)
annotation(gcf,'textbox'        , [0.65 0 0.09946 0.11] , ...
               'String'         , {'x_{k}'}             , ...
               'FontSize'       , 18                    , ...
               'FitBoxToText'   , 'off'                 , ...
               'LineStyle'      , 'none'                );
% x^(k) + v^(k)
annotation(gcf,'textbox'        , [0.76 0 0.09946 0.11] ,...
               'String'         , {'x_{k}+d_{k}'}       ,...
               'FontSize'       , 18                    ,...
               'FitBoxToText'   , 'off'                 ,...
               'LineStyle'      , 'none'                );

axis([xmin, xmax, ymin, ymax]);
set(gca, 'XTick', [Xk, maximum] , ...
    'XTickLabel', {'', ''}      , ...
    'YTick', []                 , ...
    'FontSize', 16              , ...
    'Box', 'on'                 , ...
    'LineWidth',2               );

printPmtkFigure('newtonsMethodNonConvex');
end
