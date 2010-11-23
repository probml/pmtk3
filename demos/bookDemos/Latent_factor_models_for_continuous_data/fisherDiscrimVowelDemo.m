%% Reproduce fig 4.11 of "Elements of statistical learning" 2e
%
%%

% This file is from pmtk3.googlecode.com

loadData('vowelTrain'); % from http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/vowel.train
[N,D] = size(Xtrain);
C = max(ytrain);

% PCA projection to 2d
[B,Z] = pcaPmtk(Xtrain, 2);
muC = zeros(C,D);
for c=1:C
  muC(c,:) = mean(Xtrain(ytrain==c,:),1);
end
[Bmu, muC2d] = pcaPmtk(muC, 2);


%colors = pmtkColors;
% We try to match the Hastie color scheme
lightblue = [55 155 255] / 255;
orange    = [255 128 0   ] / 255;
green     = [0   255 64  ] / 255;
magenta   = [255 0   128 ] / 255;
green2    = [132 199 71  ] / 255;
cyan      = [61  220 176 ] / 255;
yellow    = [255 255 0   ] / 255;
brown     = [128 64  0   ] / 255;
blue      = [0   0   255 ] / 255;
red      = [255   0   0 ] / 255;
black      = [0   0   0 ] / 255;
gray      = [128   128   128 ] / 255;

colors = {black, blue, brown, magenta, orange, cyan, gray, yellow, black, red, green2};

%muC2d = -muC2d;
%Z  = -Z;
figure; hold on
symbols = '+ovd*.xs^d><ph';
for c=1:C
  ndx = ytrain==c;
  plot(Z(ndx,1), Z(ndx,2), symbols(c), 'color', colors{c},...
    'linewidth', 2, 'markersize', 8);
  plot(muC2d(c,1), muC2d(c,2),  'o', 'color', colors{c},...
    'linewidth', 5, 'markersize', 15);
  %text(muC2d(c,1), muC2d(c,2), sprintf('%d', c), 'fontsize', 20);
end
printPmtkFigure('fisherDiscrimVowelPCA')

% Fisher projection to 2d
[W] = fisherLdaFit(Xtrain, ytrain, 2);
W(:,1) = -W(:,1); % make it look like the Hastie figure
Xlda = Xtrain*W;
model = discrimAnalysisFit(Xlda, ytrain, 'linear');

% Plot
stipple = true;
plotDecisionBoundary(Xlda, ytrain, @(X) discrimAnalysisPredict(model,X), ...
  'stipple', stipple, 'colors', colors); 
hold on
muC2dlda =  muC*W;
for c=1:C
  ndx = ytrain==c;
  plot(muC2dlda(c,1), muC2dlda(c,2),  'o', 'color', colors{c},...
    'linewidth', 5, 'markersize', 15);
  %text(muC2dlda(c,1), muC2dlda(c,2), sprintf('%d', c), 'fontsize', 20);
end
printPmtkFigure('fisherDiscrimVowelLDA')

