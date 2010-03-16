%% Reproduce Figure 12.6 in "The elements of statistical learning" 2e 
% by Hastie, Tibshirani, Friedman
data   = loadHastieMixtureData();
Xtrain = data.X;
ytrain = convertLabelsToPM1(data.y);
Xtest  = data.xnew;
ytest  = convertLabelsToPM1(data.prob >= 0.5);
Xtrain = mkUnitVariance(center(Xtrain));
Xtest = mkUnitVariance(center(Xtest));
gammas = [5, 1, 0.5, 0.1];
Crange = logspace(-1, 3.5, 20); 

ng = numel(gammas);
nc = numel(Crange); 
testError = zeros(ng, nc); 
saveAlphas = false; %  faster
for i=1:ng
    gamma = gammas(i);
    for j=1:nc
        C = Crange(j); 
        model = svmlightFit(Xtrain, ytrain, C, gamma, 'rbf', saveAlphas); 
        yhat = svmlightPredict(model, Xtest); 
        testError(i, j) = mean(yhat ~= ytest); 
    end
end

colors = pmtkColors();
for i=1:ng
   figure;
   plot(Crange, testError(i, :), '-o', ...
        'Color',            colors{1}, ...
        'LineWidth',        2,         ...
        'MarkerFaceColor',  colors{2}, ...
        'MarkerEdgeColor',  'k',       ...
        'MarkerSize',       8          );
    set(gca, 'xscale', 'log');
    hline = horizontalLine(data.bayesError, 'LineStyle', '--', 'Color', colors{3}, 'LineWidth', 2);  
    uistack(hline, 'bottom');
    xlabel('C');
    ylabel('test error'); 
    title(['\gamma',sprintf(' = %.2f', gammas(i))]); 
    legend(hline, 'bayes error', 'location', 'NorthWest')
    
    set(gca, 'ylim',[0.1, 0.6],  'xlim', [1e-1, 1*10^(3.5)])
    box on;
end