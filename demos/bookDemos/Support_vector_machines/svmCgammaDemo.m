%% Plot CV error vs error vs gamma and C for an SVM, plus 1d slices
% Similar to Figure 12.6 in "The elements of statistical learning" 2e 
% by Hastie, Tibshirani, Friedman,
% We also show the 2D % surface similar to figure 7 in
% http://www.csie.ntu.edu.tw/~cjlin/papers/guide/guide.pdf.
% PMTKslow
%%
%% Load Data

% This file is from pmtk3.googlecode.com

setSeed(0);
data = loadData('hastieMixture'); 
y = convertLabelsToPM1(data.y);
[X, y] = shuffleRows(data.X, y); % data is ordered
%% Plot 1D CV Slices
gammas = [5, 1, 0.5, 0.1];
Crange = logspace(-1, 3.5, 15); 
plotArgs = {true, data.bayesError};  %{useLogScale, hline}
cvopts = {5, 'useSErule', false, 'doPlot', true, 'plotArgs', plotArgs}; %{nfolds, useSErule, doPlot, plotArgs}
for i=1:numel(gammas)
    gamma = gammas(i); 
    svmFit(X, y, 'kernelParam', gamma, 'C', Crange, ...
        'cvOptions', cvopts);
    title(['\gamma', sprintf(' = %.1f', gamma)]); 
    xlabel('C'); ylabel('cv error');
    printPmtkFigure(sprintf('svmCvGamma%d', 10*gamma));
end
%% Plot 2D heat map
C = logspace(-1, 3.5, 10); 
gammas = logspace(-1, 1, 10);
[model, bestParams, CVmu, CVse] = svmFit...
    (X, y, 'kernelParam', gammas, 'C', C, 'cvOptions', {5, 'useSErule', false, 'doPlot', true});
xlabel('C');
ylabel('\gamma');
set(gca, 'xscale', 'log', 'yscale', 'log'); 
t = {sprintf('best C = %.2f', bestParams(1))
    ['best \gamma', sprintf(' = %.2f', bestParams(2) )]};
title(t);
printPmtkFigure('svmCvHeatmap')
 
%% Plot 2D contour
figure
nc = numel(C);
ng = numel(gammas); 
paramSpace = gridSpace(C, gammas);
xx = reshape(paramSpace(:, 1), nc, ng); 
yy = reshape(paramSpace(:, 2), nc, ng); 
zz = reshape(CVmu, nc, ng);
contour(xx, yy, zz, 'LineWidth', 2); 
set(gca, 'xscale', 'log', 'yscale', 'log'); 
xlabel('C');
ylabel('\gamma');
printPmtkFigure('svmCvContour')

%% Plot 2D surface
figure
surf(xx, yy, zz);
set(gca, 'xscale', 'log', 'yscale', 'log'); 
xlabel('C');
ylabel('\gamma');
zlabel('cv error')
printPmtkFigure('svmCvSurf')

%%
placeFigures;
