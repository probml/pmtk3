%% robust linear regression
function linregRobustDemo()

seed = 0; setSeed(seed);
x = sort(rand(10,1));
y = 1+2*x + rand(size(x))-.5;
% add some outliers
x = [x' 0.1 0.5 0.9]';
k =  -5;
y = [y' k  k k]';

n = length(x);
Xtrain = x(:);
modelLS = linregFit(Xtrain, y);% least squares soln
xs = 0:0.1:1;
Xtest = xs(:);
yhatLS = linregPredict(modelLS, Xtest);


if 0
%% Laplace loss
modelLP = linregRobustLaplaceLinprogFit(Xtrain, y);
yhatLaplace = linregPredict(modelLP, Xtest);
legendStr ={'least squares', 'laplace'};
doPlot(x, y, {yhatLS, yhatLaplace}, legendStr);
printPmtkFigure('linregRobustLaplace')
end

%% Student loss 

% Estimate everything
modelStudent = linregRobustStudentFit(Xtrain, y);
yhatStudent = linregPredict(modelStudent, Xtest);
fprintf('student sigma2=%5.3f\n', modelStudent.sigma2)
fprintf('student dof=%5.3f\n', modelStudent.dof)
legendStr ={'least squares', ...
  sprintf('student, mle dof=%5.3f', modelStudent.dof)};

% Estimate w and s2, fix dof
dofs = [1,5,10];
for i=1:length(dofs)
  modelStudentDof{i} = linregRobustStudentFit(Xtrain, y, dofs(i));
  yhatStudentDof{i} = linregPredict(modelStudentDof{i}, Xtest);
  legendStr{i+2} = sprintf('student dof = %5.3f', dofs(i));
end
doPlot(x, y, {yhatLS, yhatStudent, yhatStudentDof{:}}, legendStr);
printPmtkFigure('linregRobustStudentFixedDof')

% Estimate w, fix s2 and dof
X1 =  [ones(n,1) Xtrain];
wLS = X1 \ y;
sigma2  = var(y - X1*wLS);
for i=1:length(dofs)
  modelStudentDof2{i} = linregRobustStudentFit(Xtrain, y, dofs(i), sigma2);
  yhatStudentDof2{i} = linregPredict(modelStudentDof2{i}, Xtest);
  legendStr{i+2} = sprintf('student fixed s2, dof = %5.3f', dofs(i));
end
doPlot(x, y, {yhatLS, yhatStudent, yhatStudentDof2{:}}, legendStr);
printPmtkFigure('linregRobustStudentFixedDofSigma')


if 0
%% Laplace and student on same plot
legendStr ={'least squares', 'laplace', sprintf('student, dof=%5.3f', modelStudent.dof)};
doPlot(x, y,  {yhatLS, yhatLaplace, yhatStudent}, legendStr)
printPmtkFigure('linregRobustLaplaceStudent')


%% Huber loss
if 1
  legendStr = {'Least Squares'};
  deltas = [1 5];
  for i=1:length(deltas)
    delta = deltas(i);
    modelHuber = linregRobustHuberFit(Xtrain, y, delta);
    yhatHuber{i} = linregPredict(modelHuber, Xtest); %#ok
    legendStr{1+i} = sprintf('Huber loss %3.1f', delta);
  end
  doPlot(x, y, {yhatLS, yhatHuber{:}}, legendStr);
  printPmtkFigure('linregRobustHuber')
end
end
end

%%%

function doPlot(x, y, yhat, legendStr)
if ~iscell(yhat), yhat = {yhat}; end
K = length(yhat);
xs = 0:0.1:1;
styles = {'r-o', 'b:s', 'g-.*', 'k-.+', 'c--v', 'y-^'};
figure; hold on;
plot(x,y,'ko','linewidth',2)
h = [];
for i=1:K
  h(i) = plot(xs, yhat{i}, styles{i}, 'linewidth', 2, 'markersize', 10);
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
  legend(h, legendStr, 'location', 'east');
end
end
