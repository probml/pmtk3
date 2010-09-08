%% pmtk3 interface to mlcomp
%
%% What is mlcomp?
% <http://mlcomp.org/ mlcomp> is "a free website for objectively
% comparing machine learning programs across various datasets for
% multiple problem domains". The basic idea is that it creates
% a data x algorithm table,
% which stores the performance of
%  many different algorithms on many different data sets.
% Users can upload their own data and/or their own algorithms.
% Users can also request to run any given algorithm on any
% given dataset.
% Thus the table of results is filled out on-demand,
% by users requesting that certain (d,a) entries be computed.
%
% All computation is done on Amazon's EC2 cloud computing
% service. Users must upload programs as standalone executables
% which must conform to a simple interface.
% Alternatively, they can upload an octave file, 'run.m',
% with the following interface:
%
% |octave -qf run learn trainingDataFileName|
%
% |octave -qf run predict testDataFileName predictionsFileName| 
% 
% Thus run.m takes 1 or 3 arguments,
% where the first argument must be the string
% 'learn' or 'predict',
% and the other arguments are filenames.
% The data must be formated
% according to the instructions
% <http://mlcomp.org/help/quickstart.html here>.

%% The pmtk interface to mlcomp
% Since some of pmtk also runs in octave, it would be nice
% to be able to apply any pmtk algorithm to any dataset in mlcomp,
% and thus compare pmtk's performance to other methods.
% However, you first have to generate an octave program
% with the right interface.
% Fortunately, this process can be automated by calling
% mlcompCompiler.m .
% The interface is as follows
%
% |mlcompCompiler(fitFn, predictFn, outputDir, fitOpts, predictOpts)|
%
% where
%
% * |fitFn| is of the form |model = fitFn(X, y, fitOpts{:})|
% * |predictFn| is of the form |yhat = predictFn(model, X, predictOpts{:})|
% * |outputDir| is a directory to which the various files will be written
% * |fitOpts| is an optional cell array passed to fitFn
% * |predictOpts| is an optional cell array passed to predictFn
%
% For example, consider the following
%
%  |mlcompCompiler('linregFitSimple', 'linregPredict', localdir, {0.1})|
%
% This generates the stand-alone octave program
% called 'run', shown
% <http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/mlcompExample-run.txt here>.
% This contains all of the other functions
% potentially called by linregFitSimple and linregPredict,
% which is why it is so long.
% (In fact, I  have shortened it somewhat by not including
% all these dependencies, to make things clearer.)
% Obviously all the (potentially) called functions must
% be octave compatible. In particular, this means
% they should have an 'end' statement at the end of the file,
% a convention matlab does not require.
% (See <http://code.google.com/p/yagtom/wiki/Octave this link>
% for more information on octave/ matlab compatibility issues.)
