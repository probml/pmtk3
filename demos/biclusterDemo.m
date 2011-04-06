%% Bicluster Demo
%PMTKreallySlow
%%

% This file is from pmtk3.googlecode.com

function [] = biclusterDemo()
setSeed(0);
nRow = 100;
nCol = 30;
dummyData = zeros(nRow, nCol);
nLevels = 3;

%% First a really simple example

fprintf('First discover a bicluster in a really simple example -- binary data\n')
dummyData(5:5:end, 5:5:end) = 1;
patternDummyRows = 5:5:size(dummyData,1);
patternDummyCols = 5:5:size(dummyData,2);
setSeed(1);
[dummyBcRow, dummyBcCol, dummyRowProb, dummyColProb] = biclusteringGibbs(dummyData, 'trace', true, 'plot', false, 'allRowThres', 0.7, 'allColThres', 0.8);

h = figure();
axes('Position', [0.15, 0.15, 0.8, 0.8]);
colormap('gray')
imagesc(dummyRowProb{1}'*dummyColProb{1})
title('Posterior Probability');

rowExp = axes('Position', [0.07, 0.15, 0.01, 0.8]);
imagesc(colvec(dummyRowProb{1}));
set(rowExp, 'XTick', []); set(rowExp, 'YTick', []);

rowTrue = axes('Position', [0.01, 0.15, 0.01, 0.8]);
rowTruth = zeros(nRow, 1); rowTruth(patternDummyRows) = 1;
imagesc(rowTruth);
set(rowTrue, 'XTick', []); set(rowTrue, 'YTick', []);

colExp = axes('Position', [0.15, 0.07, 0.8, 0.01]);
imagesc(rowvec(dummyColProb{1}));
set(colExp, 'XTick', []); set(colExp, 'YTick', []);

colTrue = axes('Position', [0.15, 0.01, 0.8, 0.01]);
colTruth = zeros(1,nCol); colTruth(patternDummyCols) = 1;
imagesc(colTruth);
set(colTrue, 'XTick', []); set(colTrue, 'YTick', []);
printPmtkFigure('dummyBiclusterProb');

figure(); colormap('gray'); imagesc(dummyData);
title('Data Matrix');
printPmtkFigure('dummyBiclusterData');

%% Now a more difficult example
fprintf('\n\nNow we try a more difficult example, similar to the example from Fig. 2 in Shen et al (2003): Biclustering Microarray Data in Gibbs Sampling\n')
uniData = unidrndPMTK(nLevels, [nRow, nCol]);
% now we embed the pattern
patternRowSize = 25;
patternColSize = 8;
sharp = 0.95;

p = rand(nLevels,patternColSize)*(1-sharp); % a sharp multinomial distributions
idx = sub2ind(size(p), unidrndPMTK(nLevels, 1, patternColSize), 1:patternColSize);
p(idx) = sharp;
p = normalize(p, 1);

patternUniRows = unidrndPMTK(nRow, patternRowSize);
patternUniCols = unidrndPMTK(nCol, patternColSize);
fprintf('True rows: %s\n', mat2str(sort(patternUniRows')))
fprintf('True columns: %s\n', mat2str(sort(patternUniCols')))
for k=1:patternColSize
  uniData(patternUniRows,patternUniCols(k)) = sampleDiscrete(p(:,k), patternRowSize, 1);
end

setSeed(2);
[uniBcRow, uniBcCol, uniRowProb, uniColProb] = biclusteringGibbs(uniData, 'plot', false, 'allRowThres', 0.7, 'allColThres', 0.8);
figure();
%subplot('Position', [0.15, 0.15, 0.2, 0.8]);
subplot('Position', [0.15, 0.15, 0.8, 0.8]);
colormap('gray')
imagesc(uniRowProb{1}'*uniColProb{1})
title('Posterior Probabilities');

C = length(uniBcRow);
for c=1:C % loop really not needed, since this is an example with one bicluster
  rowExp = subplot('Position', [0.07 - (c-1)*0.02, 0.15, 0.01, 0.8]);
  imagesc(colvec(uniRowProb{c}));
  set(rowExp, 'XTick', []); set(rowExp, 'YTick', []);

  colExp = axes('Position', [0.15, 0.07 - (c-1)*0.02, 0.8, 0.01]);
  imagesc(rowvec(uniColProb{c}));
  set(colExp, 'XTick', []); set(colExp, 'YTick', []);
end

rowTrue = axes('Position', [0.01, 0.15, 0.01, 0.8]);
rowTruth = zeros(nRow, 1); rowTruth(patternUniRows) = 1;
imagesc(rowTruth);
set(rowTrue, 'XTick', []); set(rowTrue, 'YTick', []);

colTrue = axes('Position', [0.15, 0.01, 0.8, 0.01]);
colTruth = zeros(1,nCol); colTruth(patternUniCols) = 1;
imagesc(colTruth);
set(colTrue, 'XTick', []); set(colTrue, 'YTick', []);
printPmtkFigure('uniBiclusterProb');

figure(); imagesc(uniData); colormap('gray');
title('True Data Matrix')
printPmtkFigure('uniBiclusterData');

% Permuted rows and columns
%figure();
%colormap('gray');
%permuteRows = [sort(patternUniRows'), setdiff(1:nRow, patternUniRows)];
%permuteCols = [sort(patternUniCols'), setdiff(1:nCol, patternUniCols)];
%imagesc(uniData(permuteRows, permuteCols));
%title('Data matrix with permuted rows and columns based on truth');
%keyboard
plotPermute({patternUniRows}, {patternUniCols}, uniData);
title('Data matrix with permuted rows and columns based on truth');
%Y0 = 1/2; Y1 = length(patternUniRows) + 1/2; X0 = 1/2; X1 = length(patternUniCols) + 1/2;
%Xpoint = [X0, X0, X0, X1; ...
%          X1, X1, X0, X1];
%Ypoint = [Y0, Y1, Y0, Y0; ...
%          Y0, Y1, Y1, Y1];
%line(Xpoint, Ypoint, 'color', 'red', 'linewidth', 3);
printPmtkFigure('uniBiclusterDataPermuteTrue');
%keyboard
plotPermute(uniBcRow, uniBcCol, uniData);
title('Data matrix with permuted rows and columns based on discovery');
printPmtkFigure('uniBiclusterDataPermuteDiscovery')
%figure(); colormap('gray'); subplot(2,1,1);
%subplot('Position', [0.75, 0.15, 0.2, 0.35]);
%imagesc(uniData(uniBcRow{1}, uniBcCol{1}));
%title('Discovered Bicluster');
%subplot(2,1,2);
%subplot('Position', [0.75, 0.60, 0.2, 0.35]);
%imagesc(uniData(patternUniRows, patternUniCols));
%title('True Bicluster');
%printPmtkFigure('uniBiclusterTruthDiscovered');

%% Now an example with multiple biclusters
fprintf('\n\nNow multiple biclusters on a larger data matrix\n')
clear data
nRow = 200;
nCol = 40;
setSeed(103);
data = unidrndPMTK(nLevels, [nRow, nCol]);
truecount = 3;
patternRowSizeVec = [40, 25, 35];
patternColSizeVec = [7, 10, 8];
rowperm = randperm(nRow); colperm = randperm(nCol);
%p = [sharp, normalize(ones(1,nLevels-1))*(1-sharp)]; % a sharp multinomial distribution
sharp = 0.95;
%p = perms(p);
%p = unique(p, 'rows');
for j=1:truecount
  % now we embed the pattern
  patternRowSize = patternRowSizeVec(j);
  patternColSize = patternColSizeVec(j);
  %patternRows{j} = randsample(nRow, patternRowSize);
  %patternCols{j} = randsample(nCol, patternColSize);
  patternRows{j} = rowperm(1:patternRowSize);
  patternCols{j} = colperm(1:patternColSize);
  rowOverlap = unidrndPMTK(5); colOverlap = unidrndPMTK(3);
  rowperm = rowperm((patternRowSize - rowOverlap + 1):end);
  colperm = colperm((patternColSize - colOverlap + 1):end);
  fprintf('True rows: %s\n', mat2str(sort(patternRows{j}')))
  fprintf('True columns: %s\n', mat2str(sort(patternCols{j}')))

  p = rand(nLevels,patternColSize)*(1-sharp); % a sharp multinomial distributions
  idx = sub2ind(size(p), unidrndPMTK(nLevels, 1, patternColSize), 1:patternColSize);
  p(idx) = sharp;
  p = normalize(p, 1);

  for k=1:patternColSize
% Here was the problem.  We were using the first three rows of the matrix p to generate the hidden biclusters
% The second two rows were the same, ie: there really was only two biclusters.  Fixed above
    data(patternRows{j}, patternCols{j}(k)) = sampleDiscrete(p(:,k), patternRowSize, 1);
  end
end

setSeed(3);
[multBcRow, multBcCol, multRowPost, multColPost] = biclusteringGibbs(data, 'plot', false, 'allRowThres', 0.7, 'allColThres', 0.8);

%figure();
%colormap('gray');
%dataPermute = zeros(nRow,nCol);
%permuteRows = zeros(1, 0);
%permuteCols = zeros(1, 0);
%for j=1:truecount
%  newrows = sort(setdiff(patternRows{j}', permuteRows));
%  permuteRows = [permuteRows, newrows];
%
%  newcols = sort(setdiff(patternCols{j}', permuteCols));
%  permuteCols = [permuteCols, newcols];
%end
%permuteRows = [permuteRows, setdiff(1:nRow, permuteRows)];
%permuteCols = [permuteCols, setdiff(1:nCol, permuteCols)];
%imagesc(data(permuteRows, permuteCols));
%title('Data matrix with permuted rows and columns');
plotPermute(patternRows, patternCols, data);
title('Data matrix with permuted rows and columns based on truth');
printPmtkFigure('multBiclusterDataPermuteTrue');

plotPermute(multBcRow, multBcCol, data);
title('Data matrix with permuted rows and columns based on discovery');
printPmtkFigure('multBiclusterDataPermuteDiscovered');

figure();
%subplot('Position', [0.15, 0.15, 0.45, 0.8]);
subplot('Position', [0.15, 0.15, 0.8, 0.80]);
colormap('gray');
imagesc(data);
title('True Data Matrix')

C = length(multBcRow);
for c=1:C
  rowExp = subplot('Position', [0.07 - (c-1)*0.02, 0.15, 0.01, 0.80]);
  imagesc(colvec(multRowPost{c}));
  set(rowExp, 'XTick', []); set(rowExp, 'YTick', []);

  colExp = subplot('Position', [0.15, 0.07 - (c-1)*0.02, 0.80, 0.01]);
  imagesc(multColPost{c});
  set(colExp, 'XTick', []); set(colExp, 'YTick', []);
end

rowTruth = zeros(nRow, 1);
colTruth = zeros(nCol, 1);
for j=1:truecount
  rowTruth(patternRows{j}) = j;
  colTruth(patternCols{j}) = j;
end

rowTrue = subplot('Position', [0.01, 0.15, 0.01, 0.80]);
imagesc(colvec(rowTruth));
set(rowTrue, 'XTick', []); set(rowTrue, 'YTick', []);
colTrue = subplot('Position', [0.15, 0.01, 0.80, 0.01]);
imagesc(rowvec(colTruth));
set(colTrue, 'XTick', []); set(colTrue, 'YTick', []);
printPmtkFigure('multBiclusterProb');

figure(); colormap('gray');
for c=1:max(C, truecount)
  truth = subplot(2, max(C, truecount), c);
  if(c <= C)
    imagesc(data(multBcRow{c}, multBcCol{c}));
    set(truth, 'XTick', []); set(truth, 'YTick', []);
    title(sprintf('Discovered Bicluster %d', c));
  end
end
for j=1:max(C,truecount);
  truth = subplot(2, max(C, truecount), max(C, truecount) + j);
  if(j <= truecount)
    imagesc(data(patternRows{j}, patternCols{j}));
    set(truth, 'XTick', []); set(truth, 'YTick', []);
    title(sprintf('True Bicluster %d', j));
  end
end
printPmtkFigure('multBiclusterDiscovered');

end

function [] = plotPermute(matRows, matCols, data)

  [nRow, nCol] = size(data);
  permuteRows = zeros(1, 0);
  permuteCols = zeros(1, 0);
  nSets = length(matRows);
  for j=1:nSets

%    Y0 = 1/2 + length(permuteRows) - length(intersect(matRows{j}, permuteRows));
%%    X0 = 1/2 + length(permuteCols) - length(intersect(matCols{j}, permuteCols));

    newrows = rowvec(setdiff(matRows{j}, permuteRows));
    permuteRows = [permuteRows, sort(newrows)];
  
    newcols = rowvec(setdiff(matCols{j}, permuteCols));
    permuteCols = [permuteCols, sort(newcols)];

%    Y1 = Y0 + length(newrows);
%    X1 = X0 + length(newcols);
%    Xpoint{j} = [X0, X0, X0, X1; ...
%              X1, X1, X0, X1];
%    Ypoint{j} = [Y0, Y1, Y0, Y0; ...
%              Y0, Y1, Y1, Y1];
  end
  permuteRows = [permuteRows, setdiff(1:nRow, permuteRows)];
  permuteCols = [permuteCols, setdiff(1:nCol, permuteCols)];
  figure();
  colormap('gray');
  imagesc(data(permuteRows, permuteCols));
%  for j=1:nSets
%    line(Xpoint{j}, Ypoint{j}, 'color', 'red', 'linewidth', 3);
%  end
%  for j=1:nSets
%    startX = length(cell2mat(matRows(1:(j-1)))) + 1/2;
%    endX = length(cell2mat(matRows(1:j))) + 1/2;
%    startY = length(cell2mat(matCols(1:(j-1)))) + 1/2;
%    endY = length(cell2mat(matCols(1:j))) + 1/2;
%    boxX = [startX, startX, startX, startX; ...
%            endX, endX, startX, startX];
%    boxY = [startY, endY, startY, endY; ...
%            startY, endY, startY, endY];
%    line(boxX, boxY, 'color', 'red', 'linewidth', 3);
%  end
end
