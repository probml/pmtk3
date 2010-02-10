%% Plot the full L1 regularization path for the prostate data set
load prostate
w = lars(X, y, 'lasso');
lambdas = recoverLambdaFromLarsWeights(X, y, w);
figure;
plot(w, '-o','LineWidth', 2);
legend(names{1:size(X, 2)}, 'Location', 'NorthWest');
set(gca,'YLim', [-0.3, 1.3]);
title('LASSO path on prostate cancer data');
xlabel('shrinkage factor s(\lambda)');
ylabel('regression weights');
set(gca, 'XTick', 1:2:10);
set(gca, 'XTickLabel', {'0', '0.25', '0.5', '0.75','1'});
printPmtkFigure lassoPathProstate