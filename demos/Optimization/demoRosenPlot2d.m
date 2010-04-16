%% Plot the Rosenbrock function

rangexy = [-2 2 -1.5 1.5];
fn = @(x)log(rosen(x)); 
figure;
plotSurface(fn, rangexy);
shading interp;
view([-40 60]);
figure;
plotContour(fn, rangexy);
