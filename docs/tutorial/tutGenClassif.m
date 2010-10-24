%% Supervised learning using generative models in pmtk3
%
% Generative models for classification/ regression are joint models of the
% outputs and inputs
% of the form $p(y,x|\theta)$.
% We consider various examples below.
%
%% Naive Bayes classifier
% We now a simple kind of generative classifier
% called naive Bayes, which is a model of the form
%%
% $$p(y,x|\theta) = p(y|\pi) \prod_{j=1}^D p(x_j|y,\theta)$$
%%
% We can fit and predict with this model using
% naiveBayesFit.m and  naiveBayesPredict.m
% For simplicity, the current implementation
% assumes  all the features are binary,
% so $p(x_j|y=c,\theta) = Ber(x_j|\theta_{jc})$.
% It fits by MAP estimation
% with a vague Dirichlet prior (add-one-smoothing).
% Typically results are not too sensitive to the
% setting of this prior (unlike discriminative models).
%
% Below is an example (from naiveBayesBowDemo.m )
% which fits a model to some bag of words data,
% and then classifies a test set.
%%
loadData('XwindowsDocData'); % 900x600, 2 classes Xwindows vs MSwindows
Xtrain = xtrain; Xtest = xtest;
model = naiveBayesFit(Xtrain, ytrain);
ypred_train = naiveBayesPredict(model, Xtrain);
err_train = mean(zeroOneLossFn(ytrain, ypred_train));
ypred_test = naiveBayesPredict(model, Xtest);
err_test = mean(zeroOneLossFn(ytest, ypred_test));
fprintf('misclassification rates  on train = %5.2f pc, on test = %5.2f pc\n', ...
    err_train*100, err_test*100);
%%
% See also naiveBayesMnistDemo.m for application of NBC
% to classify binarized MNIST digits.
%
% It is simple to modify NBC to handle missing data in X
% at training and test time; this is left as an exercise
% to the reader.

%% Discriminant analysis
% Discriminant analysis is a generative classifier where
% the class conditional density  is a multivariate Gaussian:
%%
% $$p(y=c,x|\theta) = \mbox{discrete}(y|\pi) N(x|\mu_c,\Sigma_c)$$
%%
% PMTK supports the following variants of this model:
%%
% <html>
% <table border=1>
% <TR ALIGN=left>
% <td> Type
% <td> Description
% <tr>
% <td> QDA
% <td> $\Sigma_c$ is different for each class.
% Induces quadratic decision boundaries.
% <tr>
% <td> LDA 
% <td>  $\Sigma_c=\Sigma$ is the same (tied) for each class.
% Induces linear decision boundaries.
% <tr>
% <td> DDA
% <td> $\Sigma_c$ is diagonal, so the features are conditionally
% independent; this is an example of a naive Bayes classifier.
% Induces linear decision boundaries.
% <tr>
% <td> RDA
% <td> Regularized LDA; uses MAP estimation for $\Sigma$.
% <tr>
% <td> shrunkenCentroids
% <td> Diagonal LDA with L1 shrinkage on offsets (see below)
% </table>
% </html>
%%
% We give more details below.

%% QDA/ LDA/ NBC
% Below we give an example (from discrimAnalysisFisherIrisDemo.m )
% of how to fit a QDA/LDA/ diagDA model.
% We apply it to a subset of the Fisher Iris dataset.
%%
loadData('fisherIrisData')
X = meas(51:end, 1:2);  % for illustrations use 2 species, 2 features
labels = species(51:end);
[y, support] = canonizeLabels(labels);
types = {'quadratic', 'linear', 'diag'};
for tt=1:length(types)
  model = discrimAnalysisFit(X, y, types{tt});
  h = plotDecisionBoundary(X, y, @(Xtest)discrimAnalysisPredict(model, Xtest));
  title(sprintf('Discrim. analysis of type %s', types{tt}));
  if ~isOctave
    legend(h, support, 'Location', 'NorthWest');
    set(gca, 'Xtick', 5:8, 'Ytick', 2:0.5:4);
  end
  xlabel('X_1'); ylabel('X_2');
end
%%

%% Regularized discriminant analysis
% When fitting a discriminant analysis model 
% we will encounter numerical problems
% when estimating $\Sigma$ when N < D, even if we use
% a tied  covariance matrix (i.e., one shared across classes, a method
% known as linear discriminant analysis).
% A simple solution is to use a Wishart prior to compute a MAP
% estimate of $\Sigma$. This is called regularized discriminant analysis,
% and can be fit using |discrimAnalysisFit(X, y, 'rda', lambda)|,
% where |lambda| controls the amount of regularization.
% See cancerHighDimClassifDemo.m
% for an example, which reproduces
% table 18.1 from
% <http://www-stat.stanford.edu/~tibs/ElemStatLearn/ Elements of statistical learning>
% 2nd edn p656.
% (We don't run this demo here since it requires computing
% the SVD of Xtrain (which has size 144* 16063, with 14 classes)
% which takes
% more seconds than we are willing to wait (about 40 sec)).
%

%% Nearest shrunken centroid
% Consider a naive Bayes model in which the diagonal covariance
% is tied. This has O(D) parameters for the covariance, but O(C D) for the mean.
% To prevent overfitting, we can shrink the class-conditional means towards
% the overall mean; this technique is called nearest shrunken centroids. We
% can fit this model using |discrimAnalysisFit(X, y, 'shrunkenCentroids',
% lambda)|. We given an example of this below (from
%  shrunkenCentroidsSRBCTdemo.m ),
% where we apply the method to
% the SRBCT gene microarray dataset, whose training set
% has size 63*2308 with  C=4 classes.
% This roughly reproduces figure 18.4 from
% <http://www-stat.stanford.edu/~tibs/ElemStatLearn/ Elements of statistical learning>
% 2nd edn p656.
%%
close all; clear all;
loadData('srbct');

Xtest = Xtest(~isnan(ytest), :);
ytest = ytest(~isnan(ytest));

fitFn = @(X,y,lam)  discrimAnalysisFit(X, y, 'shrunkenCentroids', 'lambda',lam);
predictFn = @(model, X)  discrimAnalysisPredict(model, X);

lambdas = linspace(0, 8, 20);
nTrain = length(ytrain);
nTest = length(ytest);
for i=1:length(lambdas)
    model = fitFn(Xtrain, ytrain, lambdas(i));
    yhatTrain = predictFn(model, Xtrain);
    yhatTest = predictFn(model, Xtest);
    errTrain(i) = sum(zeroOneLossFn(yhatTrain, ytrain))/nTrain;
    errTest(i) = sum(zeroOneLossFn(yhatTest, ytest))/nTest;
    numgenes(i) = sum(model.shrunkenCentroids(:) ~= 0);
end

figure;
plot(lambdas, errTrain, 'gx-', lambdas, errTest, 'bo--',...
  'MarkerSize', 10, 'linewidth', 2)
legend('Training', 'Test', 'Location', 'northwest');
xlabel('Amount of shrinkage')
ylabel('misclassification rate')
title('SRBCT data')
%%
% We can also visualize the MAP (blue) and ML (gray) estimate of the means
% for each class.
%% 
bestModel = fitFn(Xtrain, ytrain, 4);
centShrunk = bestModel.shrunkenCentroids;
model = fitFn(Xtrain, ytrain, 0);
centUnshrunk = model.shrunkenCentroids;

[numGroups D] = size(centShrunk);
for g=1:3 % numGroups
    %subplot(4,1,g);
    figure; hold on;
    plot(1:D, centUnshrunk(g,:), 'Color', [.8 .8 .8]);
    plot(1:D, centShrunk(g,:), 'b', 'LineWidth', 2);
    title(sprintf('Class %d', g));
    hold off;
    printPmtkFigure(sprintf('shrunkenCentroidsClass%d', g))
end


%% Robust discriminant analysis
% We can use any joint probability model for the class conditional
% density in a generative classifier.
% To train we just call |generativeClassifierFit(fitFn, X, y)|
% where |fitFn| fits $p(x|y=c,\theta)$.
% To predict we just call 
% |[yhat, post] = generativeClassifierPredict(logprobFn, model, Xtest)|,
% where |logprobFn| computes $p(x|y=c,\theta)$.
%
% As a simple example, we can make each class conditional density
% be a Student distribution, to implement robust discriminant
% analysis. Here is part of robustDiscrimAnalysisBankruptcyDemo.m 
% which illustrates the syntax:
%
% |modelS = generativeClassifierFit(@studentFit, Xtrain, ytrain)|
% |[yhat] = generativeClassifierPredict(@studentLogprob, modelS, Xtest)|
%
% Now we run the entire demo, which uses Student and Gaussian
% class conditional densities, as well as the QDA code.
% We see that the Student distribution is more robust
% than the Gaussian, and that the QDA code gives the same
% results as using a Gaussian model inside the generative
% classifier code, as it should
%%
robustDiscrimAnalysisBankruptcyDemo
%%

%% Using HMMs as class conditional densities
% As a more interesting example, consider the problem of classifying time series,
% such as spoken digits.
% Since each data vector has variable length, it is natural
% to use a Markov or hidden Markov model for the class conditional
% densities.
% (HMMs are discussed in more detail 
% tutLVM.html .)
% For real-valued data, a linear-Gaussian Markov model is not
% expressive enough, but an HMM with Gaussian emissions
% is quite flexible.
%
% Suppose we have two sequences, corresponding to the spoken words
% "four" and "five". We can train and test the model
% using the code below
% (from isolatedWordClassificationWithHmmsDemo.m ).
% It fits two HMMs, one per class.
%%
loadData('speechDataDigits4And5'); 
% Xtrain{i} is a 13 x T(i) sequence of MFCC data, where T(i) is the length
nstates = 5;
setSeed(0); 
Xtrain = [train4'; train5'];
ytrain = [repmat(4, numel(train4), 1) ; repmat(5, numel(train5), 1)];
[Xtrain, ytrain] = shuffleRows(Xtrain, ytrain);
Xtest = test45'; 
ytest = labels'; 
[Xtest, ytest] = shuffleRows(Xtest, ytest); 
% Initial Guess for params
pi0 = [1, 0, 0, 0, 0];
transmat0 = normalize(diag(ones(nstates, 1)) + ...
            diag(ones(nstates-1, 1), 1), 2);
% Fit
fitArgs = {'pi0', pi0, 'trans0', transmat0, 'maxIter', 10, 'verbose', true};
fitFn   = @(X)hmmFit(X, nstates, 'gauss', fitArgs{:}); 
model = generativeClassifierFit(fitFn, Xtrain, ytrain); 
% Predict
logprobFn = @hmmLogprob;
[yhat, post] = generativeClassifierPredict(logprobFn, model, Xtest);
nerrors = sum(yhat ~= ytest)
%%

%% K-nearest neighbor classifier
% One can view a KNN classifier as a generative
% classifier where the class conditional density is a non-parametric
% kernel density estimator.
% Below we give an example where we apply
% a 1-NN classifier to a subset of the MNIST digit set
% (from mnistKNNdemo.m : see mnist1NNdemo.m for special-purpose
% code that can handle the full dataset).
%%
loadData('mnistAll');
trainndx = 1:10000;
testndx =  1:1000;
ntrain = length(trainndx);
ntest = length(testndx);
Xtrain = double(reshape(mnist.train_images(:,:,trainndx),28*28,ntrain)');
Xtest  = double(reshape(mnist.test_images(:,:,testndx),28*28,ntest)');
ytrain = (mnist.train_labels(trainndx));
ytest  = (mnist.test_labels(testndx));
clear mnist trainndx testndx; % save space

m = knnFit(Xtrain, ytrain, 1);
ypred = knnPredict(m, Xtest);
errorRate = mean(ypred ~= ytest);
fprintf('Error Rate: %.2f%%\n',100*errorRate);
%%
% Below are the test error rates and running times (train + test)
% for 1NN on different sizes of training and test data
% (generated using mnist1NNdemo.m  ).
% Note that the standard training set is 60k 
% and the standard test set is 10k.
% Reassuringly, our error rate of 3.09% for 1NN on this standard
% train/ test split is the same as that
% reported  by Kenneth Wilder at
% <http://yann.lecun.com/exdb/mnist/ this league table>.
%%
% <html>
% <table border=1>
% <TR ALIGN=left>
% <td> Ntrain
% <td> Ntest
% <td> Error rate
% <td> Time
% <tr>
% <td> 60k
% <td> 10k
% <td> 3.09%
% <td> 255s
% <tr>
% <td> 60k
% <td> 1k
% <td> 3.80%
% <td> 8s
% <tr>
% <td>  10k
% <td> 1k
% <td> 8.00%
% <td> 1.39s
% </table>
% </html>
%%
% From this, we see that increasing the size of the training
% set dramatically reduces the error rate (perhaps a symptom of
% overfitting?). Also, increasing the size of the test set
% dramatically increases the cost of testing (due to the need
% to loop over mini-batches of examples, to save memory).

