%% Plot the Rosenbrock function
%
%%

% This file is from pmtk3.googlecode.com

rangexy = [-2 2 -1.5 1.5];
fn = @(x)log(rosen(x)); 
figure;
plotSurface(fn, rangexy);
shading interp;
view([-40 60]);
printPmtkFigure('rosenSurf');
figure();
plotContour(fn, rangexy);
printPmtkFigure('rosenContour');
