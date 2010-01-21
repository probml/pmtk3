
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
Xtrain = x(:);
modelLS = linregFit(Xtrain, y);% least squares soln
hold on
xs = 0:0.1:1;
Xtest = xs(:);
h = [];
yhatLS = linregPredict(modelLS, Xtest);
h(1)=plot(xs, yhatLS, styles{1},'linewidth',2, 'markersize', 10);

modelLP = linregRobustLaplaceLinprog1dFit(Xtrain, y);
yhatLP = linregPredict(modelLP, Xtest);
h(2) = plot(xs, yhatLP, styles{2}, 'linewidth',2, 'markersize', 10);
if isOctave()
    legend({'data', 'least squares', 'laplace'}, 'location', 'northwest')
else
    legend(h, {'least squares', 'laplace'}, 'location', 'northwest')
end
set(gca,'ylim',[-6 4])
printPmtkFigure('linregRobust')

%% Huber loss

figure; hold on;
plot(x,y,'ko','linewidth',2)
h = [];
h(1) = plot(xs,yhatLS, styles{1},'linewidth',2, 'markersize', 10);
legendStr = {'Least Squares'};

deltas = [1 5];
for i=1:length(deltas)
   delta = deltas(i);
   modelHuber = linregRobustHuberFit(Xtrain, y, delta);
   yhatHuber = linregPredict(modelHuber, Xtest);
   str = sprintf('%s.-', colors(i+1));
   h(1+i) = plot(xs, yhatHuber, styles{i+1}, 'linewidth', 2, 'markersize', 10);
   legendStr{1+i} = sprintf('Huber loss %3.1f', delta);
end

if isOctave()
    legendStr = [{'Data'}, legendStr];
    legend(legendStr, 'location', 'east');
else
    legend(h, legendStr, 'location', 'east');
end
%axis_pct
set(gca,'ylim',[-6 4])
printPmtkFigure('linregRobustHuber')

