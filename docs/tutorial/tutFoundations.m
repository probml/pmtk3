%% Basics of  pmtk3


%% Overall design of PMTK3
% PMTK3 has an object oriented design.
% That is, it can be thought of as defining a series of 'classes',
% representing different kinds of probabilistic models.
% Each class  supports
% various 'methods', which perform certain operations.
% These methods are often implemented in a functional way.
%
% We don't actually use Matlab's object oriented system,
% because this does not work in Octave.
% In addition, some users find such code harder to understand,
% and it can be slower than non OO code.
% Instead, each model 'object' (an instance of a model 'class')
% is actually just a structure, containing various fields.
% And each method is just a regular function, whose name begins
% with the class name. The first argument to a method 
% must be a model struct. 
%
% As an example, below we create a 2d Gaussian model
% and then draw 5 samples from it
%%
m = gaussCreate([0 0], eye(2))
setSeed(0); X = gaussSample(m, 5)
%%
% The function gaussCreate.m is called a constructor,
% since it creates an instance of the class.
% The function gaussSample.m is a method.
% The methods that are supported depend on the type of model;
% details are given below.
%
% To provide some overall structure, we group the model
% classes into two major types:
%%
% * unconditional / unsupervised
% * conditional / supervised
%%
% These support different functions, as we explain below.

%% Conditional (supervised) models 
% This is a model of the form $p(y|x, \theta)$
% or $p(y,x|\theta)$,
% where x is the set of covariates/ inputs,
% and y is the response/ output. 
% If $y \in R$, we are performing regression;
% if $y \in \{1,\ldots,C\}$, we are performing classification.
% (Structured output classification is not yet supported.)
%
% All conditional models should support the functions listed below.
% (Note that we treat generative classifiers as conditional
% models, since they implement the interface below.)
% In the table,  'foo' is the name of the model class
% and '...' refers to optional or model-specific arguments
% (these will be explained later).
%%
% <html>
% <TABLE BORDER=3 CELLPADDING=5 WIDTH="100%" >
% <TR ALIGN=left>
% <TH WIDTH=40%  BGCOLOR=#00CCFF><FONT COLOR=000000>Method</FONT></TH>
% <TH WIDTH=60% BGCOLOR=#00CCFF><FONT COLOR=000000>Description</FONT></TH>
% </TR>
% <tr>
% <td> m = fooCreate(...)
% <td> Constructor
% <tr>
% <td> m = fooFit(X, y, ...)
% <td> Constructor. Usually computes the MLE
% or MAP parameter estimate, using various priors and  fitting algorithms.
% X is an N*D design matrix, where
% N is the number of training cases, and D is the dimensionality
% of the distribution being fit. 
% y is the N*1 response vector.
% <tr>
% <td> [yhat, py] = fooPredict(m, X, ...)
% <td> The meaning of the outputs depends on the model class.
% For classification, yhat(i) = argmax p(y|X(i,:), m),
% and py(i,c) = p(y=c|X(i,:), m). 
% (Note that some models cannot
% produce probabilistic outputs. In such cases, py may be
% undefined.)
% For regression, yhat(i) = E[y|X(i,:),m]
% and py(i) = Var[y|X(i,:), m]. 
% <tr>
% <td>
% <tr>
% </table>
% </html>
%%
% We discuss supervised models in more detail
% <http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/html/tutSupervised.html here>.
% An auto-generated list of all the supervised models and their methods
% is shown
% <http://pmtk3.googlecode.com/svn/trunk/docs/modelsByMethods/supervisedModels.html here>.


%% Unconditional (unsupervised) models
% An unconditional model is of the form $p(x|\theta)$,
% where x is potentially vector valued.
% Such models support the following functions,
% although in some cases, some functions may not
% yet have been implemented for a particular model class.
%%
% <html>
% <TABLE BORDER=3 CELLPADDING=5 WIDTH="100%" >
% <TR ALIGN=left>
% <TH WIDTH=40%  BGCOLOR=#00CCFF><FONT COLOR=000000>Method</FONT></TH>
% <TH WIDTH=60% BGCOLOR=#00CCFF><FONT COLOR=000000>Description</FONT></TH>
% </TR>
% <td>  m = fooCreate(...)
% <td> Constructor. Allows user to specify the parameters 'by hand',
% as well as specifying optional arguments to be used by fitting
% and/or inference routines.
% <tr>
% <td> m = fooFit(X,  ...)
% <td> Constructor. Usually computes the MLE
% or MAP parameter estimate, using various priors and  fitting algorithms.
% X is an N*D design matrix.
% For some models, X may contain NaN's, representing missing values.
% <tr>
% <td> m = fooTrain(model, X,  ...)
% <td> Train a model that has already been constructed.
%  Mostly used by graphical models.
% <tr>
% <td>  X = fooSample(m, N)
% <td> X(i,:) = sample from model m, i=1:N
% <tr>
% <td>  L = fooLogprob(m, X)
% <td> L(i) = log p(X(i,:)| m) 
% For some models, X may contain NaN's, representing missing values.
% <tr>
% <td>  Xhat = fooReconstruct(m, X)
% <td> Xhat(i,:) = reconstruction of X(i,:) after compressing
% and decompressing through the model.
% <tr>
% </table>
% </html>
%%
%
% Unconditional models are subdivided
% into various subtypes, as follows:
%
% * basic (standard parametric distributions e.g., Gauss)
% * latent (mixture models, latent factor models, HMMs, RBMs, etc)
% * graphical (models which require specifying an arbitrary graph structure)
%
% We discuss these  below.

%% Basic models
% Basic models support the functions listed above.
% We have already illustrated the gaussCreate.m constructor
% and gaussSample.m method.
% We now discuss some other methods.
%
% First, as a piece of useful shorthand,
% some widely used basic models (such as Gaussian)
% let you write |fooSample(params,N)|
% instead of |fooSample(fooCreate(params),N)|.
% For example, we can write |gaussSample(mu,Sigma,N)|
%%
setSeed(0); gaussSample(zeros(2,1), eye(2), 5)
%%
% Now we illustrate model fitting.
% First we use MLE to fit a D=50 dimensional Gaussian
% to N = 1000 data points.
%%
N = 1000; D = 50;
X = rand(N,D);
m = gaussFit(X);
%%
% Let us check that the resulting  estimate
%  matches the usual MLE formula:
%%
assert(approxeq(m.mu, mean(X)))
assert(approxeq(m.Sigma, cov(X, 1)))
%%
% Let us also check that $\hat{\Sigma}$ is well conditioned
%%
cond(m.Sigma)
%%
% Now consider what happens when N=50.
%%
m2 = gaussFit(X(1:50,:));
cond(m2.Sigma)
%% 
% We see that the resulting matrix is close
% to singular. MLE only works well when $N \gg D$. In all
% other cases, we should use MAP estimation.
% We can do this as follows, using a weak data-dependent prior:
%%
m3 = gaussFit(X(1:50,:), 'map');
cond(m3.Sigma)
%%
% See shrinkCovDemo.m
% for a more extensive demo of regularized estimation
% of covariance matrices.
%%
% Now let us consider another useful operation:
% evaluating the log likelihood of a dataset:
%%
L = gaussLogprob(m3, X);
size(L)
%%
% where L(i) is the logprob of X(i,:).
% For Gaussians, we can also write
% |gaussLogprob(mu, Sigma, X)|,
% but note that this is a different order
% of parameters to that used by the stats toolbox,
% which uses |mvnpdf(X, mu, Sigma)|.
%
% These methods behave similarly on other models.
% A list of all the basic models and their methods is shown
% <http://pmtk3.googlecode.com/svn/trunk/docs/modelsByMethods/basicModels.html here>.


%% Latent variable models
% From a functional point of view, an LVM supports
% all the methods for a generic unconditional model,
% plus the following functions.
%%
% <html>
% <TABLE BORDER=3 CELLPADDING=5 WIDTH="100%" >
% <TR ALIGN=left>
% <TH WIDTH=40%  BGCOLOR=#00CCFF><FONT COLOR=000000>Method</FONT></TH>
% <TH WIDTH=60% BGCOLOR=#00CCFF><FONT COLOR=000000>Description</FONT></TH>
% </TR>
% <td> [pz, pz2] = fooInferLatent(m, X).
% <td> This is an unsupervised version of predict.
% If the LVM has discrete latent variables,
% pz(i,k) = p(z=k|X(i,:), m).
% If the LVM has continuous latent variables,
% pz(i,:) = E(z|X(i,:), m)
% and pz2(i,:,:) = Cov(z|X(i,:), m).
% <tr>
% <td> [z] = fooMapLatent(m, X).
% <td> If the LVM has discrete latent variables,
% z(i,:) = argmax p(z|X(i,:), m).
% Not supported for continuous latent variables.
% <tr>
% </table>
% </html>
%%
% We discuss LVMs in more detail 
% in tutLVM.html .



%% Graphical models
% From a functional point of view, a GM supports
% all the methods for a generic unconditional model,
% plus the following functions.
%%
% <html>
% <TABLE BORDER=3 CELLPADDING=5 WIDTH="100%" >
% <TR ALIGN=left>
% <TH WIDTH=40%  BGCOLOR=#00CCFF><FONT COLOR=000000>Method</FONT></TH>
% <TH WIDTH=60% BGCOLOR=#00CCFF><FONT COLOR=000000>Description</FONT></TH>
% </TR>
% <tr> 
% <td> [bel] = fooInferNodes(m, evidence).
% <td> Here bel{i} is a tabular factor, 
% where  bel{i}.T(k) is the probability node i is in state k, given the
% evidence.
% The evidence can be specified
% in several different ways. See 
% <a href =
% "http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/html/tutGM.html">here</a>
% for details.
% <tr> 
% <td> yhat = fooMap(m, evidence)
% <td> Computes argmax p(y|ev, m), which is a (joint) posterior mode.
% <tr>
% </table>
% </html>
%%
% We discuss graphical models in more detail
% <http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/html/tutGM.html
% here>.



%% Summary of models and methods
% 
% A summary of the abstract classes and their main methods is shown below
%%
% <html>
% <img src="http://pmtk3.googlecode.com/svn/trunk/docs/classSystem/modelsMethodsTree.png">.
% </html>
%%


%% Bayesian methods
% So far, we have been focusing on fitting models
% using ML or MAP parameter estimation.
% Furthermore, prediction and inference has used
% the plugin approximation, treating the parameters
% as known constants.
% PMTK3 has some limited support for Bayesian methods
% of model fitting/ prediction, as we now explain.
%
% For model fitting, instead of |fooFit|
% use |fooFitBayes|
% which computes $p(\theta|D)$.
%
% For supervised models, instead of |fooPredict|  use
%  |fooPredictBayes|, which computes
%%
% $$p(y|x,D) = \int p(y|x,\theta) p(\theta|D) d\theta$$
%%
%
% For unsupervised models, instead of |fooInfer| use
% |fooInferBayes|, which computes
%%
% $$p(z|x,D) = \int p(z|x,\theta) p(\theta|D) d\theta$$
%%
% where z are the latent variables and x are the observed variables.
% Also, instead of |fooLogprob| use |fooLogprobBayes|, which computes
%%
% $$L(i) = \int p(X(i,:) | \theta) p(\theta|D) d\theta$$
%%
% We will give examples of these methods later.
%
% 'Under the hood', things are a bit more complicated in
% the Bayesian context compared to MAP estimation, since we don't store model
% parameters but a posterior distribution over model 
% parameters. Furthermore, the form of this posterior
% may differ across inference algorithms, e.g., it might
% be a Gaussian approximation, or a bag of samples.
% However, from a user's point of view, these details
% should not matter. 
% 

%% Passing in optional arguments
% Many functions take a large number of optional arguments.
% For example, linregFit.m (which fits a linear regression model)
% has the following interface
%
%  [model] = linregFit(X, y, varargin)
%
% varargin represents a variable number of arguments.
% The optional arguments, and their default values, are printed
% when you type |help('linregFit')|.
%%
help linregFit
%%
% The meaning of these arguments will be explained
% later.
%
% There are two ways to specify the optional arguments:
% 1) a set of name, value pairs eg.
%%
clear all
N=10; D = 2; X = rand(N, D); y = rand(N,1);
m1 = linregFit(X, y, 'regType', 'L2', 'lambda', 2)
%%
% 2) a struct, where the fields are named after the optional
% arguments, eg.
%%
s.regType = 'L2'; 
s.lambda = 2;
m2 = linregFit(X, y, s)
%%
% As a sanity check, let us check these are equal
%%
assert(approxeq(m1.w, m2.w))
%%
% Internally, these optional arguments are processed using
% process_options.m , written by Mark Paskin, and
% prepareArgs.m , written by Matt Dunham.
% For more detals, see
% <http://yagtom.googlecode.com/svn/trunk/html/writingFunctions.html#40
% this entry> in our Matlab tutorial.


%% Generally useful Matlab functions
% PMTK uses a large number of  functions
% that are useful for many different purposes outside of
% machine learning. Many of these are stored
% in our <http://code.google.com/p/matlabtools/ matlabTools> site.
% Others are built-in to Matlab, as explained
% in our <http://code.google.com/p/yagtom/ Matlab tutorial>.
% We mention just a few of the most useful ones below
%
% * whoCallsMe.m : |whoCallsMe('foo')| will list all files that call foo.m
% * wwhich.m : which with wildcards. eg |wwhich('foo*')|
% prints full filenames of all files starting
%   with the string 'foo', and |wwhich('*foo*')| finds
% files with 'foo' anywhere in their name.
% * |edit('foo')| will open foo.m in the matlab editor.
% This lets you look at (and modify) the source code.
%    This also works
%   for built-in Matlab functions. 
%   Be careful not to change things accidently!.
% * |help('foo')| prints any initial documentation for foo.m that
%     the implementer may have provided; all builtin Matlab functions
%     are properly documented. Unfortuntately that is not the case for
%     all the PMTK functions... but you can always read the source :)
% * |doc('foo')| opens the html documentation for built-in function foo.m
% * placeFigures.m : this lays out all the currently open figures
%   so you can see them all at the same time
% * |dbstop if error| : open the debugger if there is an error.
% See <http://yagtom.googlecode.com/svn/trunk/html/debugging.html here>
% for more info on debugging.
% * printPmtkFigure.m : this is used to make figures for
% <http://www.cs.ubc.ca/~murphyk/MLbook/index.html my book>. It uses
% <http://www.mathworks.com/matlabcentral/fileexchange/23629 export_fig.m>
% to make the figures 'camera ready'. If you want to include figures
% in your own document, you can modify printPmtkFigure appropriately.

%% Auto-generated documentation
% Below we give some links to auto-generated documentation,
% which list all the functions and demos in the toolbox.
% These automatically generated lists can help you
% find relevant functions/ demos that may not be mentioned in the tutorial.
%
% * <http://code.google.com/p/pmtk3/wiki/synopsisPages Functions>,
% with brief (1 line) descriptions and links to their source
% * <http://code.google.com/p/pmtk3/wiki/Demos Demos>, published as html pages
% including the results of running each demo.
 