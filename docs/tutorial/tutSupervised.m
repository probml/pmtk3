%% Supervised learning in pmtk3
%
%% Models
% An auto-generated list of all the supervised models and their methods
% is shown
% <http://pmtk3.googlecode.com/svn/trunk/docs/modelsByMethods/supervisedModels.html here>.
%
% Below we show a manually created list 
%  (in alphabetical order)
% of pmtk models that are designed for 
% supervised learning.
% We have classified the models based on whether they can be used for
% classification $y \in \{1,\ldots,C\}$,
% regression $y \in R$, or both; whether they are generative models of
% the form $p(y,x|\theta)$ or discriminative models of the form $p(y|x,\theta)$;
% and whether they are parametric (so $\theta$ has fixed size) or
% non-parametric (so $\theta$ grows as the training set gets larger).
% We assume y is a low-dimensional scalar.
% Models for multivariate conditional density estimation (structured output
% classification/ regression) will be added later.
%
%%
% <html>
% <table border=1>
% <TR ALIGN=left>
% <td> Model 
% <td> Description
% <td> Classif/regr
% <td> Gen/Discr
% <td> Param/non
% <tr>
% <td> discrimAnalysis
% <td> Discriminant analysis (linear, quadratic, regularized, shrunken) 
% <td> Classif
% <td> Gen
% <td> Param
% <tr>
% <td> generativeClassifier
% <td> Any class conditional density 
% <td> Classif
% <td> Gen
% <td> Param
% <tr>
% <td> knn
% <td> k nearest neighbors
% <td> Classif
% <td> Gen
% <td> Nonparam
% <tr>
% <td> linreg
% <td> Linear regression
% <td> Regr
% <td> Discrim
% <td> Param
% <tr>
% <td> logreg
% <td> Logistic regression 
% <td> Classif
% <td> Discrim
% <td> Param
% <tr>
% <td> mixexp
% <td> Mixture of experts
% <td> Both
% <td> Discrim
% <td> Param
% <tr>
% <td> mlp
% <td> multi-layer perceptron (aka feedforward neural network)
% <td> Both
% <td> Discrim
% <td> Param
% <tr>
% <td> naiveBayes
% <td> Naive Bayes classifier
% <td> Classif
% <td> Gen
% <td> Param
% <tr> 
% <td> rbm
% <td> Restricted Boltzmann machine
% <td> Classif
% <td> Gen
% <td> Param
% <tr> 
% <td> rvm
% <td> Relevance vector machine
% <td> Both
% <td> Discrim
% <td> Nonparam
% <tr>
% <td> smlr
% <td> Sparse multinomial logistic regression
% <td> Both
% <td> Discrim
% <td> Nonparam
% <tr>
% <td> svm
% <td> Support vector machine
% <td> Both
% <td> Discrim
% <td> Nonparam
% </table>
% </html>
%%
% More models may be added in the future.
%
%
%% Creating a model
% To create a model of type 'foo', use one of the following
%%
% * |model = fooCreate(...)| % manually specify parameters
% * |model = fooFit(X, y, ...)| % Compute ML or MAP estimate of params
% * |model = fooFitBayes(X, y, ...)| % Compute posterior of params
%%
% where
%
% *  '...' refers to optional arguments (see below)
% * X  is an N*D design matrix containing the training data,
%  where N is the number of training cases and D is the number of features.
% * y is an N*1 response vector, which can be real-valued (regression),
%     0/1 or -1/+1 (binary classification), or 1:C (multi-class).
%
% If X contains missing values, represented as NaNs,
% it is best to use a generative model (although not all
% models currently support this functionality).
% NaNs in y correspond to semi-supervised learning, which
% is not yet supported.
%
% The output of create/ fit is a Matlab structure
% representing the model.
% However, we will sometimes call it an 'object',
% since it behaves like one in many respects.
%
% In the case of |fooCreate| and |fooFit|, the parameters are point estimates.
% In the case of |fooFitBayes|, we store a distribution over
% the parameters, 
% which may be represented parameterically
% or as a bag of samples. The details will be explained later.


%% Using a model for prediction
% Once the model has been created, you can use it to make predictions
%  as follows
%
%%
%  [yhat, py] = fooPredict(model, Xtest) % plugin approximation
%  [yhat, py] = fooPredictBayes(model, Xtest) % posterior predictive
%%
% Here Xtest is an Ntest*D matrix of test inputs,
% and yhat is an Ntest*1 vector of predicted responses of the same type
% as ytrain (e.g., if ytrain was {-1,+1}, then ytest will also be {-1,+1};
% if ytrain was {1,2}, then ytest will be converted to {1,2} as well.)
% For regression yhat is the predicted mean, for classification yhat is the
% predicted mode (most probable class label).
% The meaning of py depends on the model, as follows:
%   
% * For regression, py is an Ntest*1 vector of predicted variances.
% * For binary classification, py is an Ntest*1 vector of the probability of being in class 1.
% * For multi-class, py is an Ntest*C matrix, where py(i,c) = p(y=c|Xtest(i,:),params)
%
% The difference between |predict| and |predictBayes| is as follows.
% |predict| computes
%%
% $$p(y|x,\hat{\theta}(D))$$
%%
% which "plugs in" a point estimate
% of the parameters, while |predictBayes| computes
%%
% $$p(y|x,D) = \int p(y|x,\theta) p(\theta|D) d\theta$
%%
% which integrates out the unknown parameter.
% This is called the (posterior) predictive density.
% In practice, the Bayesian approach results in similar (often identical)
% values for yhat, but quite different values for py. In particular, the
% uncertainty is reflected more accurately in the Bayesian approach, as we
% illustrate later.

%% More information
% Because supervised learning is such a large topic,
% we have created various sub-pages describing different approaches
% in more detail,
% as follows:
%
% * <http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/html/tutRegr.html
% Parametric discriminative models for regression>
% * <http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/html/tutDiscrimClassif.html
% Parametric discriminative models for classification>
% * <http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/html/tutKernelClassif.html
% Kernel-based discriminative models for classification and regression>
% * <http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/html/tutGenClassif.html
% Generative models for classification and regression>
% * <http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/html/tutMLcomp.html
% PMTK interface to mlcomp>, a website for comparing machine learning
% algorithms
