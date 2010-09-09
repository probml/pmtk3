%% Illustration of a saddle point
%
%%

% This file is from pmtk3.googlecode.com

function saddle()



h = @(x,z) cos(x.^2).*exp(x.^2 - z.^2);
f = @(x) h(x, 0); 
g = @(z) h(0, z);
d = -0.8:0.08:0.8;
[X, Y] = meshgrid(d, d);
Z = h(X, Y);
figure; hold on;
p1 = surf(X, Y, Z);
p2 = plot3(d, zeros(size(d)), f(d), '-', 'LineWidth', 6, 'Color', [0 0 0.6]);
d(d==0) = [];
p3 = plot3(zeros(size(d)), d, g(d), '.r', 'MarkerSize', 40);
colormap([0.35 0.6 0.9]);
view([23.5 22]);
box on;
set(gca, 'XTick', [], 'YTick', [], 'ZTick', []);
placeFigures('square', false);
leg = legend([p2,p3], {'f(x)', 'g(z)'}, 'FontSize', 22);
set(leg, 'Position', [0.3762 0.7655 0.07324 0.09367]);

annotation(gcf,'textbox',[0.6012 0.06965 0.05947 0.06468], ...
    'String'       , {'x'}  ,...
    'FontSize'     , 28     ,...
    'FitBoxToText' , 'off'  ,...
    'LineStyle'    , 'none' );

annotation(gcf, 'textbox', [0.7198 0.08458 0.05947 0.09194], ...
    'String', {'z'},...
    'FontSize', 28,...
    'FitBoxToText', 'off',...
    'LineStyle','none');

printPmtkFigure saddle;




end
