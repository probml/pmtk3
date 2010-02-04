%% Plot an MVN in 2D

%%  
model = struct('mu', [0 0]', 'Sigma', [2 1.8; 1.8 2]);
plotContour(@(x)gausspdf(x, model.mu, model.Sigma), [-5 5 -10 10]);
title('full');
printPmtkFigure gaussPlot2dDemoContourFull
plotSurface(@(x)gausspdf(x, model.mu, model.Sigma));
title('full');
printPmtkFigure gaussPlot2dDemoSurfFull
%% Decorrelate
[U, D] = eig(model.Sigma);
S1 = U'*model.Sigma*U;

plotContour(@(x)gausspdf(x, model.mu, S1), [-5 5 -10 10]);
title('diagonal');
printPmtkFigure gaussPlot2dDemoSurfDiag
plotSurface(@(x)gausspdf(x, model.mu, S1), [-5 5 -10 10]);
title('diagonal');
printPmtkFigure gaussPlot2dDemoContourDiag
%% Whiten
A = sqrt(inv(D))*U';
mu2 = A*model.mu;
S2  = A*model.Sigma*A'; % might not be numerically equal to I
assert(approxeq(S2, eye(2)))
S2 = eye(2); % to ensure picture is pretty

% we plot centered on original mu, not shifted mu

plotContour(@(x)gausspdf(x, model.mu, S2), [-5 5 -5 5]);
title spherical 
axis equal
printPmtkFigure gaussPlot2dDemoContourSpherical
plotSurface(@(x)gausspdf(x, model.mu, S2), [-5 5 -5 5]);
title spherical;
printPmtkFigure gaussPlot2dDemoSurfSpherical