%% Plot the full L1 regularization path for the prostate data set
function lassoPathProstate()
loadData('prostate');
%% First use LARS
w = lars(X, y, 'lasso');
lambdas = recoverLambdaFromLarsWeights(X, y, w);
plotWeights(w, names, lambdas);

%%
% Now we simulate the above result using pmtk
maxLambda    =  log10(lambdaMaxLasso(X, y));
NL = 100;
lambdas  =  logspace(maxLambda, -2, NL); 
[N,D] = size(X); %#ok
weights = zeros(NL,D);
for i=1:NL
  model = linregFit(X, y, 'lambda', lambdas(i), 'regType', 'L1', 'preproc', []);
  weights(i,:) = rowvec(model.w);
end
plotWeights(weights, names, lambdas);

end

function plotWeights(w, names, lambdas)
figure;
%plot(lambdas, w, '-o','LineWidth', 2);
plot(w, '-o','LineWidth', 2);
legend(names{1:end-1}, 'Location', 'NorthWest');
title('LASSO path on prostate cancer data');
%xlabel('shrinkage factor s(\lambda)');
xlabel('lambda')
ylabel('regression weights');
%set(gca,'YLim', [-0.3, 1.3]);
%set(gca, 'XTick', 1:2:10);
%set(gca, 'XTickLabel', {'0', '0.25', '0.5', '0.75','1'});
printPmtkFigure lassoPathProstate
end
