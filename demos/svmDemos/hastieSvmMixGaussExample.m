%% Reproduce figures 12.2, 12.3 and 12.5 in Hastie ESL 2nd ed.

%% Generate Data
% Generate data as per Hastie 2ed, pg 16:
% two classes, blue and orange, each with a mixture of 10, 2D Gaussians.
setSeed(0);
ncenters = 10; 
d = 2;

blueMix.Sigma = repmat(eye(d)./5, [1, 1, ncenters]);
blueMix.mixweight = normalize(ones(1, ncenters));
blueMix.K = ncenters;
orangeMix = blueMix;

data = loadHastieMixtureData(); % exact training data used by Hastie
means = reshape(data.means, [20, 2]);
blueMix.mu   = means(1:10, :)';
orangeMix.mu = means(11:end, :)';

Xtrain = data.X;
ytrain = data.y + 1;
[Xtrain, ytrain] = shuffleRows(Xtrain, ytrain);
bayesError = data.bayesError;

ntest = 10000;
blueTest = mixGaussSample(blueMix, ntest);
orangeTest = mixGaussSample(orangeMix, ntest); 
Xtest = [blueTest; orangeTest];
ytest = [ones(ntest, 1); 2*ones(ntest, 1)];
[Xtest, ytest] = shuffleRows(Xtest, ytest); 

genmodel.nclasses = 2;
genmodel.classConditionals = {blueMix, orangeMix};
genmodel.support = [1 2];
prior.T = [0.5;0.5];
prior.K = 2;
prior.d = 1; 
genmodel.prior = prior; 
predictFn = @(X)generativeClassifierPredict(@mixGaussLogprob, genmodel, X); 
purple = [147, 23, 147]./255;
args = {'--', 'linewidth', 2, 'linecolor', purple};



Cvalues = [10000, 0.01];
nc = numel(Cvalues);
model = cell(nc, 1); 
trainError = zeros(nc, 1);
testError  = zeros(nc, 1);
for i=1:nc
    plotDecisionBoundary(Xtrain, ytrain, predictFn, 'contourProps', args);
    model{i} = svmFit(Xtrain, ytrain, 'C', Cvalues(i), 'kernel', 'linear');
    trainError(i) = mean(ytrain ~= svmPredict(model{i}, Xtrain));
    testError(i) = mean(ytest ~= svmPredict(model{i}, Xtest));
    hold on;
    plotDecisionBoundary(Xtrain, ytrain, @(x)svmPredict(model{i},x), 'newFigure', false); 
    hold off;
end
%%

