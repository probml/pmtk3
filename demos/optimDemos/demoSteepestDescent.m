
%exactLineSearch = true;
exactLineSearch = false;

%f = @(x) 0.5*(x(:,1).^2 - x(:,2)).^2 + 0.5*(x(:,1)-1).^2;
f = @(x) aokiFn(x);
[x1 x2] = meshgrid(0:0.1:2, -0.5:0.1:3);


Z = f([x1(:), x2(:)]);
Z = reshape(Z, size(x1));
figure(1);clf
contour(x1,x2,Z,50)
hold on
h=plot(1,1,'ro'); set(h,'markersize',12,'markerfacecolor','r');


x0 = [0; 0];
global xhist
xhist = [];
if 0
  x = steepestDescent(@aokiFn, x0, 'maxIter', 10, ...
    'exactLineSearch', exactLineSearch, 'outputFn', @optimstore);
else
  %stepSize = 0.1;
  stepSize = 0.6;
  x = steepestDescent(@aokiFn, x0, 'maxIter', 20, ...
    'stepSize', stepSize, 'outputFn', @optimstore);
end
  
hold on;
plot(xhist(1,:), xhist(2,:), 'ro-');
if doPrintPmtk, printPmtkFigures('aokiSteepestExact'); end;
%title(sprintf('exact line searching %d', exactLineSearch))
%title(sprintf('step size %3.1f', stepSize))
