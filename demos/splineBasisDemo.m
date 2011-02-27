%% Ridge regression for splines
%PMTKauthor John D'Erico
%PMTKurl http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=8553&objectType=fileY

% This file is from pmtk3.googlecode.com


setSeed(0);
n = 50;
x = sort(rand(n,1));
y = sin(pi*x) + 0.2*randn(size(x));
xtest = linspace(min(x), max(x), 100);

for Nbins = [40 80]
[X, bins] = splineBasis(x, Nbins); % X(i,j) = 1 if x(i) is inside interval knot(j)
[n d] = size(X);
Xtest = splineBasis(xtest, [], bins);

D = spdiags(ones(d-1,1)*[-1 1],[0 1],d-1,d);
lambdas = [1e-1 10];
for lambda=lambdas(:)'
  [n d] = size(X);
  wridge = ([X;sqrt(lambda)*D]\[y;zeros(d-1,1)]);
  figure
  plot(x,y,'ko', 'markersize', 8);
  hold on
  yhat = Xtest*wridge;
  plot(xtest, yhat, 'r-', 'linewidth', 3);
  title(sprintf('regularized solution, N=%d, #bins = %d, %s=%5.3f', n, Nbins, '\lambda', lambda));
  printPmtkFigure(sprintf('splineBasisDemoK%dL%d', Nbins, lambda*10));
end
end
