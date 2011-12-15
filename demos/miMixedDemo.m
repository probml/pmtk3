%% Compute pairwise mutual information in autompg dataset

% This file is from pmtk3.googlecode.com


%loadData('adultCensus'); % make sure data is on path
%[data] = adultDataPreprocess;
data = loadData('autompg');

[N,D] = size(data.X);
cndx = (data.types == 'c');
XC = data.X(:, cndx);
XD = data.X(:, ~cndx);
mi = mutualInfoAllPairsMixed(XD, XC);

figure; imagesc(triu(mi));
%colormap(gray);
colorbar
%xticklabelRot(data.varNames, 90, 10, -0.2)
set(gca,'yticklabel', data.varNames);
title('pairwise mutual information in autompg data')
printPmtkFigure('miMixedDemoColor3')

