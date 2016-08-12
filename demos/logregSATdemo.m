%% Binary Logistic Regression on SAT data
% Example from Johnson and Albert p87
%% Load data

% This file is from pmtk3.googlecode.com

stat = loadData('sat');  y = stat(:,1); X = stat(:,4);

%% Fit model
pp = preprocessorCreate('addOnes', true, 'standardizeX', false);
model = logregFit(X, y, 'preproc', pp);
%[X, ndx] = sort(X);
%y = y(ndx);
[yhat, prob] = logregPredict(model, X);

%% visualize model fit for each training point
figure;
plot(X, y, 'ko', 'linewidth', 2, 'MarkerSize', 7, 'markerfacecolor', 'k');
hold on
plot(X, prob, 'ro', 'linewidth', 2,'MarkerSize', 10)
axis_pct

%% Highlight the two x's which have different labels.
plot(525, 0, 'bx', 'linewidth', 2, 'markersize', 14);
plot(525, 1, 'bx', 'linewidth', 2, 'markersize', 14);

%% Draw the decision boundary
% Solve for 0.5 = sigmoid(a + b x)
% x = (logit(0.5) - a)/b
a = model.w(1); b = model.w(2);
logit = @(p) log(p/(1-p));
xstar = (logit(0.5) - a)/b;
ylim = get(gca, 'ylim');
h=line([xstar xstar], [ylim(1) ylim(2)]);
set(h, 'color', 'k', 'linewidth', 3);
fs = 12;
xlabel('SAT score', 'fontsize', fs);
ylabel('Prob. pass class', 'fontsize', fs)
title(sprintf('Logistic regression on SAT data, threshold = %2.1f', xstar));

printPmtkFigure('logregSATdemo')

%% Linear regression
model_lin = linregFit(X, y, 'preproc', pp);
[yhat_lin] = linregPredict(model, X);
figure;
plot(X, y, 'ko', 'linewidth', 2, 'MarkerSize', 7, 'markerfacecolor', 'k');
hold on
plot(X, yhat_lin)
axis_pct
xlabel('SAT score', 'fontsize', fs);
ylabel('Predicted output', 'fontsize', fs)
title(sprintf('Linear regression on SAT data'));
printPmtkFigure('linregSATdemo')

