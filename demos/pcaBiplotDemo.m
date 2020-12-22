

% This file is from pmtk3.googlecode.com


%http://www.amstat.org/publications/jse/datasets/04cars.txt
%http://www.stat.cmu.edu/~cshalizi/350/lectures/10/cars-fixed04.dat
loadData('04cars'); % X is 387*18
X = X(:, 8:18); % use cts features, not binary
varlabels = varlabels(8:18);


%X = centerCols(X);
[X, mu, s] = standardizeCols(X);
[W, Z, evals, Xrecon, mu] = pcaPmtk(X, 2);
f1=figure;
biplotPmtk(W, 'varLabels', varlabels,  'Scores',Z);
printPmtkFigure(sprintf('pcaBiplot'))
