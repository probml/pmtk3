%% Reproduce Figure 12.6 in "The elements of statistical learning" 2e 
% by Hastie, Tibshirani, Friedman, in which we cross validate over both C
% and gamma svm parameters. We also show the 2D % surface similar to figure 7 in
% http://www.csie.ntu.edu.tw/~cjlin/papers/guide/guide.pdf.
%PMTKslow
%% Load Data
setSeed(0);
data = loadHastieMixtureData();
y = convertLabelsToPM1(data.y);
[X, y] = shuffleRows(data.X, y); % data is ordered
%% Plot 1D CV Slices
gammas = [5, 1, 0.5, 0.1];
Crange = logspace(-1, 3.5, 15); 
plotArgs = {true, data.bayesError};  %{useLogScale, hline}
cvopts = {5, false, true, plotArgs}; %{nfolds, useSErule, doPlot, plotArgs}
for i=1:numel(gammas)
    gamma = gammas(i); 
    svmlightFitCV(X, y, 'kernelParam', gamma, 'C', Crange, 'cvopts', cvopts);
    title(['\gamma', sprintf(' = %.1f', gamma)]); 
    xlabel('C'); ylabel('cv error');
    printPmtkFigure(sprintf('hastie2dCVgamma%.f', gamma));
end
%% Plot 2D heat map
C = logspace(-1, 3.5, 10); 
gammas = logspace(-1, 1, 10);
[model, bestParams, CVmu, CVse] = svmlightFitCV...
    (X, y, 'kernelParam', gammas, 'C', C, 'cvopts', {5, false, true});
xlabel('C');
ylabel('\gamma');
set(gca, 'xscale', 'log', 'yscale', 'log'); 
t = {sprintf('best C = %.2f', bestParams(1))
    ['best \gamma', sprintf(' = %.2f', bestParams(2) )]};
title(t);
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
%% Plot 2D surface
figure
surf(xx, yy, zz);
set(gca, 'xscale', 'log', 'yscale', 'log'); 
xlabel('C');
ylabel('\gamma');
zlabel('cv error')
%%
placeFigures;