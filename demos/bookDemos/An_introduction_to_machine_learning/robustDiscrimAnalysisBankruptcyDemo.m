%% Fit a student  distribution as class conditional density to the bankruptcy data
%

% This file is from pmtk3.googlecode.com


function robustDiscrimAnalysisBankruptcyDemo()

setSeed(0);
bank = loadData('bankruptcy');
N = size(bank.data,1);
perm = randperm(N);
trainNdx = perm(1:round(0.5*N));
testNdx = setdiff(perm, trainNdx);

y = bank.data(:,1);
ytrain = bank.data(trainNdx,1); % 0,1
ytest = bank.data(testNdx,1); % 0,1
X = standardizeCols(bank.data(:, 2:3));
Xtrain = X(trainNdx, :);
Xtest = X(testNdx, :);

modelS = generativeClassifierFit(@studentFit, Xtrain, ytrain); 
[yhat] = generativeClassifierPredict(@studentLogprob, modelS, Xtest);
figure;
process(modelS, yhat, Xtest, ytest, 'Student', Xtrain, ytrain);
printPmtkFigure('robustLDAstudent')

modelG = generativeClassifierFit(@gaussFit, Xtrain, ytrain); 
[yhat] = generativeClassifierPredict(@gaussLogprob, modelG, Xtest);
figure;
process(modelG, yhat, Xtest, ytest, 'Gaussian', Xtrain, ytrain);
printPmtkFigure('robustLDAgauss')

if 1
% Sanity check - should be same as using Gaussian
modelQ = discrimAnalysisFit(Xtrain, ytrain, 'QDA'); 
[yhat] = discrimAnalysisPredict(modelQ, Xtest);
figure;
process(modelQ, yhat, Xtest, ytest, 'QDA', Xtrain, ytrain);
end

end

function process(model, yhat, X, Y, name, Xtr, ytr)

if nargin < 6, Xtr = []; ytr = []; end

% Plot class conditional densities
hold on;

for c=1:2
  if strcmpi(model.modelType, 'generativeClassifier')
    mod = model.classConditionals{c};
    mu = mod.mu; Sigma = mod.Sigma;
  else
    mu = model.mu(:,c); Sigma = model.Sigma(:,:,c);
  end
	gaussPlot2d(mu, Sigma, 'color', 'k', 'plotMarker', false);
end


% indices of true and false positive/ negatives
idxbankrupt1 = find(Y == 0 & yhat(:) == 0);
idxbankrupt2 = find(Y == 0 & yhat(:) == 1);
idxsolvent1 = find(Y == 1 & yhat(:) == 1);
idxsolvent2 = find(Y == 1 & yhat(:) == 0);

% Plot data and predictions
nerrors = sum(Y ~= yhat);
h1 = plot(X(idxbankrupt1, 1), X(idxbankrupt1,2), 'bo');
plot(X(idxbankrupt2, 1), X(idxbankrupt2,2), 'ro', 'markersize', 12, 'linewidth', 3);
h2 = plot(X(idxsolvent1, 1), X(idxsolvent1,2), 'b^');
plot(X(idxsolvent2, 1), X(idxsolvent2,2), 'r^', 'markersize', 12, 'linewidth', 3);

if ~isempty(Xtr)
  % Plot training data
  plot(Xtr((ytr==0),1), Xtr((ytr==0),2), 'ko', 'markersize', 8);
  plot(Xtr((ytr==1),1), Xtr((ytr==1),2), 'k^', 'markersize', 8);
end

title(sprintf('Bankruptcy Data using %s (black = train, blue=correct, red=wrong), nerr = %d', name, nerrors ));
legend([h1, h2], 'Bankrupt', 'Solvent', 'location', 'southeast');
fprintf('Num Errors using %s: %d\n' , name, nerrors);

end
