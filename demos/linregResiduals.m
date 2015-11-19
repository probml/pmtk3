%% Residuals Demo
%
%%

% This file is from pmtk3.googlecode.com

setSeed(2);


N = 21;
[xTrainRaw, yTrain] = ...
    polyDataMake('sampling','thibaux', 'n', N);

Ntrain = length(xTrainRaw);
xTrain = [ones(Ntrain,1) xTrainRaw(:)];


X = xTrain;
y = yTrain;
%w = pinv(X'*X)*X'*y; % OLS estimate
w = X\y;
yPredTrain = xTrain*w;

xTestRaw = linspace(min(xTrainRaw), max(xTrainRaw), 100);
Ntest = length(xTestRaw);
xTest = [ones(Ntest,1) xTestRaw(:)];
yPredTest = xTest*w;

figure
hold on

% fitted line
hh = plot(xTestRaw, yPredTest,  'k-');
set(hh, 'linewidth', 3)

% individual points
h = plot(xTrainRaw, yTrain, '.b', 'markersize', 30);
set(h, 'linewidth', 2);


printPmtkFigure('linRegResidualsWithoutVerticalLines')

h = plot(xTrainRaw, yPredTrain, 'rx', 'markersize', 10);
set(h, 'linewidth', 2);

% residuals as vertical lines
for i=1:Ntrain
  h=line([xTrainRaw(i) xTrainRaw(i)], [yPredTrain(i) yTrain(i)]);
  set(h, 'linewidth', 2, 'color', 'r');
end

printPmtkFigure('linRegResidualsWithVerticalLines')


