%% Compute the full L1 regularization path for a classification
% version of the prostate data set

% This file is from pmtk3.googlecode.com


clear all
if ~glmnetInstalled
    fprintf('cannot run %s without glmnet; skipping\n', mfilename());
    return;
end
load prostateStnd
mu = mean(y);
y = (y>mu); % dichotimize
[N,D] = size(X); %#ok

pp = preprocessorCreate();
options = glmnetSet();
%options.lambda = lambdas;
%options.standardize = false;
options.nlambda = 30;

[bestModel, path] = logregFitPathCv(X, y, 'regtype', 'l1',  'preproc', pp,...
  'options', options, 'nfolds', 5);
figure;
lambdas2 = rowvec(path.lambdas);
plot(path.w', '-o', 'LineWidth', 2);
legend(names{1:size(X, 2)}, 'Location', 'NorthEast');
hold on
bestNdx = find(bestModel.lambda==lambdas2);
verticalLine(bestNdx, 'linewidth', 2, 'color', 'r');
printPmtkFigure('lassoPathProstateClassifCv')
