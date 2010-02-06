ks = [1 1.5 3];
for trial=1:length(ks)
  k = ks(trial);
  model.mixweight  = [1 1]/2;
  model.classPrior = model.mixweight;
  model.mu          = [1.5 1.5 ; -1.5 -1.5]';
  model.Sigma(:,:,1) = eye(2);
  model.Sigma(:,:,2) = k*eye(2);
  model.type        = 'quadratic'; % not tied
  
  setSeed(3); nsamples = 30;
  colors = pmtkColors();
  xyRange = [-10 10 -10 10];
  
  [X, y] = mixGaussSample(model, nsamples);
  plotDecisionBoundary(X, y, @(Xtest)discrimAnalysisPredict(model, Xtest));
  for j = 1:2
    fn = @(x)gausspdf(x, model.mu(:, j), model.Sigma(:, :, j));
    plotContour(fn, xyRange, 'LineColor', colors{j});
  end
  title(sprintf('%s = %5.3f %s', '\Sigma_2', k, '\Sigma_1'))
  axis square
  fname = sprintf('discrimAnalysisSemiTied%d', trial)
  printPmtkFigure(fname)
end