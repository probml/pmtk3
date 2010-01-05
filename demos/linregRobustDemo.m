
%% robust linear regression

%% minimize the L1 norm of the residuals using linear programming
%#author John D'Errico
%#url http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=8553&objectType=FILE

seed = 0; setSeed(seed);
x = sort(rand(10,1));
y = 1+2*x + rand(size(x))-.5;
% add some outliers
x = [x' 0.1 0.5 1.0]';
k = -5;
y = [y' k  k k]';

figure;
plot(x,y,'ko','linewidth',2)
title 'Linear data with noise and outliers'

[styles, colors, symbols] =  plotColors;
styles = {'r-o', 'b:s', 'g-.*', 'g-.+'};

n = length(x);
% least squares soln
XX = [ones(n,1) x];
w = XX \ y;
hold on
xs = 0:0.1:1;
h(1)=plot(xs,w(1) + w(2)*xs, styles{1},'linewidth',2, 'markersize', 10)

% L1 solution
f = [0 0 ones(1,2*n)]';
LB = [-inf -inf , zeros(1,2*n)];
UB = [];
Aeq = [ones(n,1), x, eye(n,n), -eye(n,n)];
beq = y;
params = linprog(f,[],[],Aeq,beq,LB,UB);
coef = params(1:2);

h(2) = plot(xs,coef(1) + coef(2)*xs, styles{2}, 'linewidth',2, 'markersize', 10)
legend(h, 'L2', 'L1', 'location', 'northwest')
%set(gca,'ylim',[-3.5 4])


%% Now use Huber loss
%#author Mark Schmidt
%#url http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html#2

legendStr = {'Least Squares','Laplace'};

deltas = [1];
options.Display = 'none';
for i=1:length(deltas)
   delta = deltas(i);
   wHuber = minFunc(@HuberLoss,w,options,XX,y,delta);
   str = sprintf('%s.-', colors(i+2));
   h(2+i) = plot(xs, wHuber(1) + wHuber(2)*xs, styles{i+2}, 'linewidth', 2, 'markersize', 10);
   legendStr{2+i} = sprintf('Huber loss %3.1f', delta);
end
legend(h, legendStr, 'location', 'east');
axis_pct
printPmtkFigure('linregRobust')

