PMTK is a collection of Matlab/Octave functions, written by Matt Dunham, Kevin Murphy and
<a href="https://github.com/probml/pmtk3/wiki/contributingAuthors">various other people</a>. The toolkit is primarily designed to accompany Kevin Murphy's textbook
<a href="http://people.cs.ubc.ca/~murphyk/MLbook">
Machine learning: a probabilistic perspective</a>, but can also be used independently of this book. The goal is to provide a unified conceptual and software framework encompassing machine learning, graphical models, and Bayesian statistics (hence the logo). (Some methods from frequentist statistics, such as cross validation, are also supported.) Since December 2011, the toolbox is in maintenance mode, meaning that bugs will be fixed, but no new features will be added (at least not by Kevin or Matt).

PMTK supports a large
variety of probabilistic models, including
linear and logistic regression models (optionally with kernels), SVMs and gaussian processes, directed and undirected
graphical models,  various kinds of latent variable models (mixtures, PCA, HMMs, etc) , etc.  Several kinds of prior are supported,
including Gaussian (L2 regularization), Laplace (L1 regularization),
Dirichlet, etc.  Many algorithms are supported, for both
Bayesian inference (including dynamic programming,
variational Bayes and MCMC) and MAP/ML estimation (including EM, 
conjugate and projected gradient methods, etc.)

PMTK builds on top of several existing packages, available from
<a href="https://github.com/probml/pmtksupport">pmtksupport</a>,
and provides a unified interface to them. In addition, it provides readable "reference" implementations of many common machine learning techniques. The vast majority of the code is written in Matlab.
 (For a brief discussion of why we chose Matlab, click 
<a href="https://github.com/probml/pmtk3/wiki/WhyMatlab">here</a>.
Most of the code also runs on
<a href="https://github.com/ubcmatlabguide/ubcmatlabguide/wiki/Octave">Octave</a>
an open-source Matlab clone.) However, in a few cases we also provide wrappers to implementations written in C,  for speed reasons. PMTK currently (October 2010) has over 67,000 lines.

PMTK contains many demos of different methods applied to  many different kinds of data sets. The demos are listed <a href="https://github.com/probml/pmtk3/wiki/Demos">here</a>.

To get the code, click on the "Download zip" button on the right hand side of github, or just clone this repository.
<a href="https://github.com/probml/pmtk3/wiki/pmtk3Documentation">Click here</a> for information on how to use the toolbox.
If you want to contribute code, please follow the guidelines
<a href = "https://github.com/probml/pmtk3/wiki/GuidelinesForContributors">here</a>,
and issue a Pull Request.


As you can tell by the name, PMTK3 is the third version of PMTK. Older versions are obsolete, but are briefly described
<a href = "https://github.com/probml/pmtk3/wiki/pmtkVersions">here</a>.


