% Reproduce fig 4.11 of "Elements of statistical learning" 2e

%#author Hannes Bretschneider

load vowel_train; % from http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/vowel.train
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
for c=1:C
  ndx = ytrain==c;
  plot(Z(ndx,1), Z(ndx,2), 'o', 'color', colors{c},...
    'linewidth', 1, 'markersize', 4);
  plot(muC2d(c,1), muC2d(c,2),  'o', 'color', colors{c},...
    'linewidth', 3, 'markersize', 10);
  text(muC2d(c,1), muC2d(c,2), sprintf('%d', c), 'fontsize', 20);
end
printPmtkFigure('fisherDiscrimVowelPCA')

% Fisher projection to 2d
Sw = (Xtrain  - muC(ytrain,:))'*(Xtrain  - muC(ytrain,:));
muOverall = mean(Xtrain, 1);
Sb = (ones(C,1)*muOverall-muC)'*(ones(C,1)*muOverall-muC);
[W,D] = eig(inv(Sw)*Sb);
W(:,1) = -W(:,1); % make it more similar to Hastie figure
Xlda = [Xtrain*W(:,1) Xtrain*W(:,2)];
model = discrimAnalysisFit(Xlda, ytrain, 'linear');

% Plot
stipple = true;
symbols = repmat('o', 1, C);
markersize = 6;
plotDecisionBoundary(Xlda, ytrain, @(X) discrimAnalysisPredict(model,X), ...
  stipple, colors, symbols, markersize);
hold on
muC2dlda = [muC*W(:,1) muC*W(:,2)];
for c=1:C
  ndx = ytrain==c;
  plot(muC2dlda(c,1), muC2dlda(c,2),  'o', 'color', colors{c},...
    'linewidth', 6, 'markersize', 12);
  text(muC2dlda(c,1), muC2dlda(c,2), sprintf('%d', c), 'fontsize', 20);
end
printPmtkFigure('fisherDiscrimVowelLDA')

