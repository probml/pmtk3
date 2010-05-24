ABOUT THESE PROGRAMS
====================

This collection of matlab programs implement and demonstrates some fo the
algorithms described in the book Rasmussen and Williams: "Gaussian Processes
for Machine Learning", the MIT Press 2006.


There are 3 subdirectories: gpml, gpml-demo and doc.

gpml: contains code which implements the algorithms. Please see the Copyright
      notice contained in the file named "Copyright".

gpml-demo: contains matlab scripts with names "demo_*.m". These provide small
      demonstrations of the various programs provided. 

doc: contains four html files providing documentation. The best place to start
      is index.html, the other pages are linked from there. This information
      is also available from http://www.GaussianProcess.org/gpml/code

When running the demos, it is assumed that your current directory is the
gpml-demo directory. Otherwise, you should manually add both the gpml-demo and
gpml directories to the matab path.


VERSION
=======

The current version of the programs is dated: 2007-07-25. Previous versions of
the code may be avaiable at http://www.gaussianprocess.org/gpml/code/old


CHANGES FROM PREVIOUS VERSIONS
==============================


Changes from the 2007-06-25 version:
------------------------------------
 
covConst.m: fixed a bug which caused an error in the derivative of the log marginal
    likelihood for certain combinations of covariance functions and approximation
    methods. (Thanks to Antonio Eleuteri for reporting the problem)

gauher.m: added the function "gauher.m" which was mistakenly missing from the 
    previous release. This caused an error for certain combinations of
    approximation method and likelihood function.

logistic.m: modified the approximation of moments calculation to use a mixture
    of cumulative Gaussian, rather than Gauss-Hermite quadrature, as the former
    turns out to be more accurate.


Changes from the 2006-09-08 version:
------------------------------------

Some code restructuring has taken place for the classification code to make it
more modular, to facilitate addition of new likelihood functions and
approximations methods. Now, all classification is done using the binaryGP
function, which (among other things) takes an approximation method and a
likelihood function as an arguments. Thus, binaryGP replaces both binaryEPGP
and binaryLapaceGP, although wrapper functions are still provided for backward
compatibility. This gives added flexibility: now EP can also be used wth the
logistic likelihood function (implemented using Gauss-Hermite quadrature).

approxEP.m: New file, containing the Expectation Propagation approximation
    method, which was previously contained in binaryEPGP.m

approxLA.m: New file, containing Laplaces approximation method, which was 
    previously contained in binaryLaplace.m 

approximations.m: New file, help for the approximation methods.

binaryEPGP.m: This file has been replaced by a wrapper (for backward
    compatibility) which calls the more general binaryGP function.

binaryGP.m: New general function to do binary classification.

binaryLaplaceGP.m: This file has been replaced by a wrapper (for backward
    compatibility) which calls the more general binaryGP function.

covMatern3iso.m, covMatern5iso.m, covNNone.m, covRQard.m, covRQiso.m,
cosSEard, covSEiso: now check more carefully, that persistent variables have
    the correct sizes, and some variable names have been modified.

cumGauss.m: New file, containing code for the cumulative Gaussian
    likelihood function

likelihoods.m: New file, help for likelihood functions

logistic.m: New file, logistic likelihood


Changes from the 2006-05-10 version:
------------------------------------

covRQard.m: bugfix: replaced x with x' and z with z' in line 36

covRQiso.m: bugfix: replaced x with x' and z with z' in line 28

minimize.m: correction: replaced "error()" with "error('')", and
            made a few cosmetic changes

binaryEPGP.m: added the line "lml = -n*log(2);" in line 77. This change
         should be largely inconsequential, but occationally may save things
         when the covariance matrix is exceptionally badly conditioned.


Changes from the 2006-04-12 version:
------------------------------------

added the "erfint" function to "binaryLaplaceGP.m". The erfint function
was missing by mistake, preventing the use of the "logistic" likelihood.


Changes from the 2006-03-29 version:
------------------------------------

added files: "covProd.m" and "covPeriodic.m"

changes: "covSEiso.m" was changed slightly to avoid the use of persistent
         variables


DATASETS
========

The datasets needed for some of the demos can be downloaded from 
http://www.GaussianProcess.org/gpml/data 



ABOUT MEX FILES
===============

Some of the programs make use of the mex facility in matlab for more efficient
implementation. However, if you don't know about how to compile mex files, you
do not need to worry about this - the code should run anyway. If you do
compile the mex files, this should be automatically detected, and the program
will run more efficiently. Particularly the demonstrations of classification
on the usps digits require a lot of computation.



COMPILING MEX FILES
===================

As mentioned above, it is not necessary to compile the mex files, but it can
speed up execution considerably. We cannot give a detailed account, but here
are some hints:

Generally, you just type "mex file.c" at the matlab prompt or in your shell to
compile, where "file.c" is the program you want to compile. There is a Makefile
which works for unix/linux on x86 machines. Just type "make".

In some cases (solve_chol.c), routines from the lapack numerical library are
used. This should pose no problem on linux. On windows, you have to 1) remove
the trailing underscore from the name of the lapack function ("dpotrs", two
occurences) and 2) pass the location of the lapack library to mex, ie
something like

  mex file.c <matlab>/extern/lib/win32/lcc/libmwlapack.lib

where <matlab> is the root of your matlab installation. If your installation
doesn't include the libmwlapack.lib you may be able to get it from

http://www.cise.ufl.edu/research/sparse/umfpack/v4.4/UMFPACKv4.4/UMFPACK/
  MATLAB/lcc_lib/

