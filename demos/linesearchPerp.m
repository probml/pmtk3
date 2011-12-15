fn = @(x) aokiFn(x);
[x1 x2] = meshgrid(0:0.01:2, -0.5:0.01:3);
Z = fn([x1(:), x2(:)]);
Z = reshape(Z, size(x1));

stepSizes = { [] }; % [] means use line search
for m=1:length(stepSizes)
  x0 = [0; 0];
  global xhist fhist %updated by optimstore
  xhist = []; fhist = [];
  stepsize = stepSizes{m};
  x = steepestDescent(fn, x0, 'maxIter', 15, ...
    'stepSize', stepsize, 'outputFn', @optimstore);
  
  figure;
  min_z = min(min(Z));
  max_z = max(max(Z));
  v = linspace(min_z, max_z, 50);
  v = sort([v, fhist]);
  contour(x1, x2, Z, v);
  %contour(x1,x2,Z,50)
  hold on
  % Plot location of global min
  h=plot(1,1,'ro'); set(h,'markersize',10,'markerfacecolor','r');
  % Plot trajectory
  plot(xhist(1,:), xhist(2,:), 'ro-');
  
  if isempty(stepsize)
    ttl = sprintf('exact line search');
    title(ttl);
    printPmtkFigure('steepestDescentDemoLS');
  else
    ttl = sprintf('step size %2.1f', stepsize);
    title(ttl);
    printPmtkFigure(sprintf('steepestDescentDemo%2.1f', stepsize));
  end
  
  xlim([0.5,1.0]);
  ylim([0.0,0.9]);
  axis square;
end