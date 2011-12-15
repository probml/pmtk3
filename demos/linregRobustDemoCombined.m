%% Robust linear regression demo
% PMTKneedsOptimToolbox linprog
%%

% This file is from pmtk3.googlecode.com

function linregRobustDemoCombined()
requireOptimToolbox
seed = 0; setSeed(seed);
x = sort(rand(10,1));
y = 1+2*x + rand(size(x))-.5;
% add some outliers
x = [x' 0.1 0.5 0.9]';
k =  -5;
y = [y' k  k k]';

n = length(x);
Xtrain = x(:);
modelLS = linregFit(Xtrain, y, 'lambda', 0);% least squares soln
xs = 0:0.1:1;
Xtest = xs(:);
yhatLS = linregPredict(modelLS, Xtest);



%% Laplace loss
modelLP = linregRobustLaplaceFitLinprog(Xtrain, y);
yhatLaplace = linregPredict(modelLP, Xtest);

%% Student loss 
modelStudent = linregRobustStudentFit(Xtrain, y);
yhatStudent = linregPredict(modelStudent, Xtest);


%% Huber loss
deltas = [1];
for i=1:length(deltas)
    delta = deltas(i);
    modelHuber = linregRobustHuberFit(Xtrain, y, delta);
    yhatHuber{i} = linregPredict(modelHuber, Xtest); %#ok
end

%% Laplace and student on same plot
legendStr ={'least squares', 'laplace', ...
    sprintf('student, %s=%3.1f', '\nu', modelStudent.dof), ...
    sprintf('Huber, %s=%3.1f', '\delta', deltas(1))
    };
doPlot(x, y,  {yhatLS, yhatLaplace, yhatStudent,...
    yhatHuber{1}}, ...
    legendStr)
printPmtkFigure('linregRobustAll')


end

%%%

function doPlot(x, y, yhat, legendStr)
if ~iscell(yhat), yhat = {yhat}; end
K = length(yhat);
xs = 0:0.1:1;
styles = {'k-.', 'b--', 'r-', 'g:'};
figure; hold on;
plot(x,y,'ko','linewidth',2)
h = [];
for i=1:K
  h(i) = plot(xs, yhat{i}, styles{i}, 'linewidth', 3, 'markersize', 10);
end
plotLegend(legendStr, h)
%axis_pct
set(gca,'ylim',[-6 4])
end

function plotLegend(legendStr, h)
if isOctave()
  legendStr = [{'Data'}, legendStr];
  legend(legendStr, 'location', 'east');
else
  legend(h, legendStr, 'location', 'east', 'fontsize', 12);
end
end
