%% Supervised learning using non-parametric discriminative models in pmtk3
%
%
%% Kernel functions
%
% One common form of basis function expansion
% is to define a new feature vector $\phi(x)$ by comparing the input
% $x$ to a set of prototypes or examplars $\mu_k$ as follows:
%%
% $$\phi(x) = (K(x,\mu_1), ..., K(x,\mu_D))$$
%%
% Here $K(x,\mu)$ is a 'kernel function',
% which in this context just means a function of two arguments.
% A common example is the Gaussian or RBF kernel
%%
% $$K(x,\mu) = \exp(-\frac{||x-\mu||^2}{2\sigma^2})$$
%%
% where $\sigma$ is the 'bandwidth'.
% This can be created using kernelRbfSigma.m .
% Alternatively, we can write
%%
% $$K(x,\mu) = \exp(-\gamma ||x-\mu||^2)$$
%%
% The quantity $\gamma=1/\sigma^2$ is known as
% the scale or precision. This can be created using kernelRbfGamma.m .
% Most software packages use this latter parameterization.
%
% Another common example is the polynomial kernel
% kernelPolyPmtk.m :
%%
% $$K(x,\mu) = (1+x^T \mu)^d$$
%%
% where d is the degree.
%
% Another common example is the linear kernel
% kernelLinearPmtk.m :
%%
% $$K(x,\mu) = x^T \mu$$
%%
% (The reason for the 'pmtk' suffix is to distinguish
% these functions from other implementations of the same concept.)
%
% Often we take the prototypes $\mu_k$ to be the training vectors (rows of $X$),
% but we don't have to.
% Some methods require that the kernel be a Mercer (positive definite)
% kernel. All of the above kernels are Mercer kernels,
% but this is not always the case.
%
% The advantages of using kernels include the following
%
% * We can apply standard parametric models (e.g., linear and logistic
% regression) to non-vectorial inputs (e.g., strings, molecular structures, etc.),
% by defining $K(x,\mu)$ to be some
% kind of function for comparing structured inputs.
% * We can increase the flexibility of the model by working in an
% enlarged feature space.
%
% Below we show an example where we fit the XOR data using kernelized
% logistic regression, with various kernels and prototypes
% (from logregXorDemo.m ).
%%
clear all; close all
[X, y] = createXORdata();
rbfSigma = 1;
polydeg  = 2;
protoTypes = [1 1; 1 5; 5 1; 5 5];
protoTypesStnd = standardizeCols(protoTypes);
kernels = {@(X1, X2)kernelRbfSigma(X1, protoTypesStnd, rbfSigma)
           @(X1, X2)kernelRbfSigma(X1, X2, rbfSigma)
           @(X1, X2)kernelPolyPmtk(X1, X2, polydeg)};
titles  = {'rbf', 'rbf prototypes', 'poly'};
for i=1:numel(kernels)
    preproc = preprocessorCreate('kernelFn', kernels{i}, 'standardizeX', true, 'addOnes', true);
    model = logregFit(X, y, 'preproc', preproc);
    yhat = logregPredict(model, X);
    errorRate = mean(yhat ~= y);
    fprintf('Error rate using %s features: %2.f%%\n', titles{i}, 100*errorRate);
    predictFcn = @(Xtest)logregPredict(model, Xtest);
    plotDecisionBoundary(X, y, predictFcn);
    if i==1
       hold on; 
       plot(protoTypes(:, 1), protoTypes(:, 2), '*k', 'linewidth', 2, 'markersize', 10)
    end
    title(titles{i});
end
%%
% In the first example, we use an RBF kernel with centers at 4
% manually chosen points, shown with black stars.
% In the second and third examples, we use an RBF and polynomial kernel,
% centered at all the training data.
% This is an example of a non-parametric model,
% since the number of parameters grows with the size of
% the training set (which makes training slow on large datasets).
% We can use sparsity promoting priors  to select a subset of the training
% data, as we illustrate below.


%% Using grid search plus cross validation to choose the kernel parameters
% We can create a grid of models, with different kernels
% and different regularizers, as shown in the example
% below ( from logregKernelDemo.m ).
% If CV does not pick a point on the edge of the grid,
% we can be faily confident we have searched over
% a reasonable range. For this reason,
% it is helpful to plot the cost surface.
%
%%
loadData('fglass'); % 6 classes, X is 214*9
X = [Xtrain; Xtest];
y = canonizeLabels([ytrain; ytest]); % class 4 is missing, so relabel 1:6
setSeed(0);
split = 0.7;
[X, y] = shuffleRows(X, y);
X      = rescaleData(standardizeCols(X));
N      = size(X, 1);
nTrain = floor(split*N);
nTest  = N - nTrain;
Xtrain = X(1:nTrain, :);
Xtest  = X(nTrain+1:end, :);
ytrain = y(1:nTrain);
ytest  = y(nTrain+1:end);
  
% 2D CV
lambdaRange     = logspace(-6, 1, 5);  
gammaRange      = logspace(-4, 4, 5);
paramRange = crossProduct(lambdaRange, gammaRange); 
regtypes = {'L2'}; %L1 is a bit better but a bit slower
for r=1:length(regtypes)
  regtype = regtypes{r};
  fitFn = @(X, y, param)...
    logregFit(X, y, 'lambda', param(1), 'regType', regtype, 'preproc', ...
    preprocessorCreate('kernelFn', @(X1, X2)kernelRbfGamma(X1, X2, param(2))));
  predictFn = @logregPredict;
  lossFn = @(ytest, yhat)mean(yhat ~= ytest);
  nfolds = 5;
  useSErule = true;
  plotCv = true;
  tic;
  [LRmodel, bestParam, LRmu, LRse] = ...
    fitCv(paramRange, fitFn, predictFn, lossFn, Xtrain, ytrain, nfolds, ...
    'useSErule', useSErule, 'doPlot', plotCv, 'params1', lambdaRange, 'params2', gammaRange);
  time(r) = toc
  yhat = logregPredict(LRmodel, Xtest);
  nerrors(r) = sum(yhat ~= ytest);
end
errRate = nerrors/nTest
%%
%
% In the example above, we just use a 5x5 grid for speed,
% but in practice one might use a 10x10 grid for a coarse
% search (possibly on a subset of the data), followed by a
% more refined search in a promising part of hyper-parameter space.
% This could all be handed off to a generic discrete optimization
% algorithm, but this is not yet supported.
% (One big advantage of Gaussian processes,
% which we will discuss later,
% is that we can use continous optimization algorithms
% to tune the kernel parameters.)

%% Sparse multinomial logistic regression (SMLR)
% We can select a subset of the training examples
% by using an L1 regularizer.
% This is called Sparse multinomial logistic regression (SMLR).
% If we use an L2 regularizer instead of L1,
% we call the method 'ridged multinomial logistic regression' or RMLR.
% (This terminology is from the paper
% <http://www.lx.it.pt/~mtf/Krishnapuram_Carin_Figueiredo_Hartemink_2005.pdf "Learning sparse Bayesian classifiers: multi-class formulation, fast
% algorithms, and generalization bounds">, Krishnapuram et al, PAMI 2005.)
%
% One way to implement smlrFit.m is to
% kernelize the data,
% and then pick the best lambda on the regularization path
% using logregFitPathCv.m (which uses
% <http://www-stat.stanford.edu/~tibs/glmnet-matlab/ glmnet>).
% Another way is call fitCv.m , which
% lets us use a different kernel basis for each fold.
% This is much slower but gives much better results.
% See smlrPathDemo.m for a comparison of these two approaches.
%
% To fit an SMLR model with an RBF kernel, and to
% cross validate over lambdaRange, use
%
% |model =  smlrFit(X,y, 'kernelFn', @(X1, X2)kernelRbfGamma(X1, X2, gamma), ...
%                    'regType', 'L1', 'lambdaRange', lambdaRange)|
%  
% regType  defaults to 'L1',
% and lambdaRange defaults to logspace(-5, 2, 10),
% so both these parameters can be omitted. The kernelFn is mandatory,
% however.
% After fitting, use smlrPredict.m to predict.

%% Relevance vector machines (RVM)
% An alternative approach to achieving sparsity is to
% use automatic relevance determination (ARD).
% The combination of kernel basis function expansion
% and ARD is known as the  relevance vector machine (RVM).
% This can be used for classification or regression.
%
% One way to fit an RVM (implemented in rvmSimpleFit.m )
% is to use kernel basis expansion followed by the ARD
% fitting feature in 
% linregFitBayes.m ; however, 
% this is rather slow.
% Instead, rvmFit.m provides a wrapper to
% Mike Tipping's 
% <http://www.vectoranomaly.com/downloads/downloads.htm SparseBayes 2.0>
% Matlab library, which implements a greedy algorithm
% that adds basis functions one at a time.
%
% To fit an RVM  with an RBF kernel, use
%
% |model =  rvmFit(X,y, 'kernelFn', @(X1, X2)kernelRbfGamma(X1, X2,
% gamma))|
%
% There is no need to specify lambdaRange, since the method
% uses ARD to estimate the hyper-parameters.
% After fitting, use rvmPredict.m to predict.
%
% Currently Tipping's package does not support multi-class
% classification. Therefore we convert the base binary classifier
% into a multi-class one using oneVsRestClassifFit.m .
% This is done internally by rvmFit.m .
%


%% Support vector machines (SVM)
% SVMs are a very popular form of non-probabilistic kernelized
% discriminative classifier. They achieve sparsity not by using
% a sparsity-promoting prior, but instead by using a hinge loss
% function when training.
%
% svmFit.m (which handles multi-class classification and regression)
% is a wrapper to several different implementations of SVMs:
%
% * svmQP: our own Matlab code (based on code originally written by Steve Gunn),
% which uses the quadprog.m function in the optimization toolbox.
% * <http://svmlight.joachims.org/ svmlight>, which is a C library
% * <http://www.csie.ntu.edu.tw/~cjlin/libsvm libsvm>, which is a C library
% * <http://www.csie.ntu.edu.tw/~cjlin/liblinear/ liblinear>, which is a C
% library
%
% The appropriate library is determined automatically based on the type
% of kernel, as follows: If you use a linear kernel, it calls liblinear;
% if you use an RBF kernel, it calls libsvm; if you use an arbitrary
% kernel (eg. a string kernel), it calls our QP code.
% (Thus it never calls svmlight by default, since libsvm seems to be
% much faster.)
%
% The function svmFitTest.m checks that all these implementations
% give the same results, up to numerical error. 
% (This should be the case since
% the objective is convex; however, some
% packages only solve the problem to a very low precision.)
%
% svmFit.m calls fitCv.m internally to choose the appropriate
% regularization constant $C = 1/\lambda$.
% It can also choose the best kernel parameter.
% Here is an example of the calling syntax.
%
% |model = svmFit(Xtrain, ytrain, 'C', logspace(-5, 1, 10),...
%     'kernel', 'rbf', 'kernelParam', logspace(-2,2,5));|
%
% After fitting, use svmPredict.m to predict.

%% Comparison of SVM, RVM, SMLR
% Let us compare various kernelized classifiers.
% (We also compare to non-kernelized logistic regression,
% as a baseline, using either L2 or L1 regularization.)
% Below we show the characteristics of some data sets
% to which we will apply the various classifiers.
% Colon and AML/ALL are gene microarray datasets,
% which is why the number of features is so large.
% Soy and forensic glass are standard datasets
% from the <http://archive.ics.uci.edu/ml/ UCI repository>.
% (All data is locally stored in
% <http://code.google.com/p/pmtkdata/ pmtkdata>.)
%
%%
% <html>
% <TABLE BORDER=3 CELLPADDING=5 WIDTH="100%" >
% <TR ALIGN=left>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000></FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>nClasses</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>nFeatures</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>nCases</FONT></TH>
% </TR>
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>soy</FONT>
% <td> 3
% <td> 35
% <td> 307
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>fglass</FONT>
% <td> 6
% <td> 9
% <td> 214
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>colon</FONT>
% <td> 2
% <td> 2000
% <td> 62
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>amlAll</FONT>
% <td> 2
% <td> 7129
% <td> 72
% </table>
% </html>
%%
%
% In linearKernelDemo.m , we compare various kernelized
% classifiers (using linear kernels) on the above data.
% (We use linear kernels so we don't have to cross validate
% over gamma in the RBF kernel.)
% Below we show the median misclassification rates on the different data sets,
% averaged over 3 random splits.
% For each split, we use 70% of the data for training and 30% for testing.
% Cross validation on the training set is then used internally,
% if necessary, to tune the regularization parameter.
%%
% <html>
% <TABLE BORDER=3 CELLPADDING=5 WIDTH="100%" >
% <TR><TH COLSPAN=7 ALIGN=center> test error rate (median over 3 trials) </font></TH></TR>
% <TR ALIGN=left>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000></FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>SVM</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>RVM</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>SMLR</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>RMLR</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>logregL2</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>logregL1</FONT></TH>
% </TR>
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>soy</FONT>
% <td> 0.108
% <td> 0.108
% <td> 0.118
% <td> 0.129
% <td> 0.710
% <td> 0.108
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>fglass</FONT>
% <td> 0.477
% <td> 0.554
% <td> 0.400
% <td> 0.431
% <td> 0.708
% <td> 0.492
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>colon</FONT>
% <td> 0.211
% <td> 0.211
% <td> 0.158
% <td> 0.211
% <td> 0.316
% <td> 0.211
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>amlAll</FONT>
% <td> 0.455
% <td> 0.227
% <td> 0.136
% <td> 0.182
% <td> 0.364
% <td> 0.182
% </table>
% </html>
%%
% In terms of median performance, all methods are similar,
% with the exception of logregL2,
% which is often much worse than the others.
%
% The error rates for all methods on the forensic glass
% data are quite high (chance would be 5/6=0.83).
% This is because we used a linear kernel,
% but we only have 9 features. Using a nonlinear kernel
% (as we did above) can sometimes help performance.
% However, on high-dim datasets, linear kernels
% are usually sufficient. Indeed, we can just as well
% work in the original feature space and not use kernels at all
% for the other 3 datasets.
%
% The error rate for SVM on AML/ALL is very high (chance is 0.5).
% Other papers have reported much better results
% for SVMs on this data (with linear kernels). This is possibly
% due to the way we do cross validation. However, it may be
% that other authors have chosen particularly favorable train/test splits.
% We find that, across the 3 folds, the number of errors were 11, 10 and 4
% (out of 22). You are welcome to read the source code to make
% sure we are being fair.
%
% It is also interesting to look at the amount of time required
% to train each model (prediction is very fast with all of these methods).
% Below we show median time in seconds.
% But beware, we are comparing apples with oranges here,
% since the packages are in different langauges:
%
% * svm  is a wrapper to C code (libsvm)
% * rvm is optimized Matlab (SparseBayes)
% * SMLR and RMLR is unoptimized Matlab.
% * logregL1path and logregL2path is a wrapper to Fortran code (glmnet)
%
%%
% <html>
% <TABLE BORDER=3 CELLPADDING=5 WIDTH="100%" >
% <TR><TH COLSPAN=7 ALIGN=center> training time in seconds (median over 3 trials) </font></TH></TR>
% <TR ALIGN=left>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000></FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>SVM</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>RVM</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>SMLR</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>RMLR</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>logregL2</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>logregL1</FONT></TH>
% </TR>
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>soy</FONT>
% <td> 0.566
% <td> 0.549
% <td> 43.770
% <td> 24.193
% <td> 0.024
% <td> 0.720
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>fglass</FONT>
% <td> 0.586
% <td> 0.146
% <td> 67.552
% <td> 30.204
% <td> 0.043
% <td> 0.684
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>colon</FONT>
% <td> 1.251
% <td> 0.028
% <td> 2.434
% <td> 2.618
% <td> 0.021
% <td> 0.418
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>amlAll</FONT>
% <td> 3.486
% <td> 0.017
% <td> 2.337
% <td> 2.569
% <td> 0.097
% <td> 1.674
% </table>
% </html>
%%
% Reproducing the above results using
% linearKernelDemo.m 
% takes about 10 minutes (on my laptop).
% However, we can run a simplified version of the demo,
% which only uses 1 random fold, and only uses the last
% two datasets. This just takes 20 seconds.
%%
clear all
tic
split = 0.7;
d = 1;

loadData('colon') % 2 class, X is 62*2000
dataSets(d).X = X;
dataSets(d).y = y;
dataSets(d).name = 'colon';
d=d+1;

loadData('amlAll'); % 2 class, X is 72*7129
X = [Xtrain; Xtest];
y = [ytrain; ytest];
dataSets(d).X = X;
dataSets(d).y = y;
dataSets(d).name = 'amlAll';
d=d+1;

dataNames = {dataSets.name};
nDataSets = numel(dataSets);
methods = {'SVM', 'RVM', 'SMLR', 'RMLR', 'logregL2path', 'logregL1path'};
nMethods = numel(methods);
for d=1:nDataSets
  X = dataSets(d).X;
  y = dataSets(d).y;
  setSeed(0); s=1;
  [X, y] = shuffleRows(X, y);
  X      = rescaleData(standardizeCols(X));
  N      = size(X, 1);
  nTrain = floor(split*N);
  nTest  = N - nTrain;
  Xtrain = X(1:nTrain, :);
  Xtest  = X(nTrain+1:end, :);
  ytrain = y(1:nTrain);
  ytest  = y(nTrain+1:end);
  
  for m=1:nMethods
    method = methods{m};
    switch lower(method)
      case 'svm'
        Crange = logspace(-6, 1, 20); % if too small, libsvm crashes!
        model = svmFit(Xtrain, ytrain, 'C', Crange,  'kernel', 'linear');
        predFn = @(m,X) svmPredict(m,X);
      case 'rvm'
        model = rvmFit(Xtrain, ytrain, 'kernelFn', @kernelLinear);
        predFn = @(m,X) rvmPredict(m,X);
      case 'smlr'
        model = smlrFit(Xtrain, ytrain,  'kernelFn', @kernelLinear);
        predFn = @(m,X) smlrPredict(m,X);
      case 'smlrpath'
        model = smlrFit(Xtrain, ytrain,  'kernelFn', @kernelLinear, 'usePath', 1);
        predFn = @(m,X) smlrPredict(m,X);
      case 'rmlr'
        model = smlrFit(Xtrain, ytrain, 'kernelFn', @kernelLinear, ...
          'regtype', 'L2');
        predFn = @(m,X) smlrPredict(m,X);
      case 'rmlrpath'
        model = smlrFit(Xtrain, ytrain, 'kernelFn', @kernelLinear, ...
          'regtype', 'L2', 'usePath', 1);
        predFn = @(m,X) smlrPredict(m,X);
      case 'logregl2path'
        model = logregFitPathCv(Xtrain, ytrain, 'regtype', 'L2');
        predFn = @(m,X) logregPredict(m,X);
      case 'logregl1path'
        model = logregFitPathCv(Xtrain, ytrain, 'regtype', 'L1');
        predFn = @(m,X) logregPredict(m,X);
    end
    saveModel{d,m,s} = model;
    
    yHat   = predFn(model, Xtest);
    nerrs  = sum(yHat ~= ytest);
    testErrRate(d,m,s) = nerrs/nTest;
    numErrors(d,m,s) = nerrs;
    maxNumErrors(d) = nTest;
  end
end
toc
fprintf('test err\n');
disp(testErrRate)
%%
% It is easy to add other classifiers and data sets to this comparison.
% For more extensive comparison of different classifiers
% on different datasets, see
% tutMLcomp.html .

%% Gaussian processes
% GPs are discussed in more detail
% <http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/html/tutGP.html
% here>.
