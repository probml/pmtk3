%% Plot a Dirichlet distribution
% Here we plot the dirichlet distribution as a function of a three
% dimensional alpha vector, which we can do as the distribtion lives on a 
% lower dimensional simplex due to the sum to one constraint. 
%% alpha > 1
xyrange = [0 1 0 1];
model.alpha = 10;
npoints = 200; 
%% 
% The dirichletLogprob function returns NaNs for values that lie outside of
% the simplex, which plot() ignores giving us the nice simplex plot. 
figure();
useLog = false;
if useLog
  plotSurface(@(X)dirichletLogprob(model, X), xyrange, 'npoints', npoints);
else
  plotSurface(@(X)exp(dirichletLogprob(model, X)), xyrange, 'npoints', npoints);
end
shading interp;
camlight right;
lighting phong;
set(gca, 'xtick', 0:0.5:1, 'ytick', 0:0.5:1);
if useLog
  zlabel('log(p)');
else
  zlabel('p')
end
title(sprintf('%s=%3.2f', '\alpha', model.alpha))
printPmtkFigure(sprintf('Dir%d', model.alpha*10))

%% alpha < 1
% Here we plot the log probability - plots of exp(logp) when alpha < 1 are
% ugly due to numerical error, but for alpha = 0.1, the plots of
% p and logp look very similar, except that exp(logp) is more sharply
% peaked around the corners. 

model.alpha = 0.5;
npoints = 500; % We need a higher resolution when alpha < 1
figure();
if useLog
  plotSurface(@(X)dirichletLogprob(model, X), xyrange, 'npoints', npoints);
else
  plotSurface(@(X)exp(dirichletLogprob(model, X)), xyrange, 'npoints', npoints);
end
view([-32 50]);
shading interp; 
camlight right;
lighting phong;
set(gca, 'xtick', 0:0.5:1, 'ytick', 0:0.5:1);
if useLog
  zlabel('log(p)');
else
  zlabel('p')
end
title(sprintf('%s=%3.2f', '\alpha', model.alpha))
printPmtkFigure(sprintf('Dir%d', model.alpha*10))
