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
% service. Users must upload their program as a standalone executable
% called 'run',
% which must conform to the following simple interface:
%
% |run learn trainingDataFileName|
%
% |run predict testDataFileName predictionsFileName| 
% 
% The data must be formated
% according to the instructions
% <http://mlcomp.org/help/quickstart.html here>.
%
% Alternatively, run can be a script file which invokes octave
% (since octave is already on the EC2 server).
% This octave function should
% take 1 or 3 arguments,
% where the first argument must be the string
% 'learn' or 'predict',
% and the other arguments are filenames.

%% The pmtk interface to mlcomp
% Since some of pmtk also runs in octave, it would be nice
% to be able to apply any pmtk algorithm to any dataset in mlcomp,
% and thus compare pmtk's performance to other methods.
% However, you first have to generate an octave program
% with the right interface.
% Fortunately, this process can be automated by calling
% mlcompCompiler.m as follows
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
% |mlcompCompiler('linregFitSimple', 'linregPredict', localdir, {0.1})|
%
% This generates the stand-alone octave program
% shown
% <http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/mlcompExample-run.txt here>.
% This contains all of the functions
% potentially called by linregFitSimple and linregPredict,
% which is why it is so long.
% (In fact, I  have shortened it somewhat by not including
% all these dependencies, to make things clearer.)
% Obviously all the (potentially) called functions must
% be octave compatible. For example,
% locally nested functions are not supported by octave.
% (See <http://code.google.com/p/yagtom/wiki/Octave this link>
% for more information on octave/ matlab compatibility issues.)
%
% In addition, since mlcompCompiler puts all the functions
% together in one huge file, each function should have an 'end'
% statement at the end, even though this is not required of
% individual functions.
% mlcompCompiler calls isEndKeywordMissing.m to test for this,
% and issue a warning if the files violate this rule.
%
% Having 'compiled' your fit/ predict functions in this way,
% you need to convert your data to mlcomp format, which can be done
% as follows
%
% |mlcompWriteData(X, y, fullfile(locadir, 'data'))|
%
% Now you can execute the following commands from
% within matlab; these will invoke octave and call
% the generated script with the relevant arguments
%
% |system(sprintf('octave -qf run learn data'));|
%
% |system(sprintf('octave -qf run predict data yhat'));|
%
% Finally, you need to read the results back from the yhat file
%
% |yhat = str2double(getText('yhat'))|
%
% The script mlcompDemo.m contains a demo of all these steps.
% 
% If things work within matlab, you should next check they
% work within octave. If so, you are ready to upload
% your files and data to mlcomp! If you upload
% a single data file,
% the mlcomp servers will automatically divide your dataset
% into a 70% train/ 30 %test split.
% However, you can also upload you own train/ test files.
%
% (Note that we do not support the |setHyperparameters|
% command used by mlcomp, since it is rather complicated.
% Besides, in our view hyper-parameter tuning should be done by
% the fitting function.)
%
%% Limitations
% The main limitation of mlcompCompiler is that all the functions
% your code uses, _or might use_, must be octave compatible.
% Unfortunately, Mark Schmidt's 
% <http://www.cs.ubc.ca/~schmidtm/Software/minFunc.html minfunc.m>
% function, which is widely used inside of pmtk (e.g., when fitting
% a simple logistic regression model), is not octave compatible,
% because he did not close his subfunctions with 'end' statements.
% (Obviously this is an easy problem to fix, but 
% any changes need to be incorporated by Mark, otherwise
% all the work will need to be repeated on the next release of minfunc...)
% We can not even use linregFit.m for similar reasons,
% since it supports L1 regularization, which calls a different
% Mark Schmidt package, which is also octave incompatible.
% 
% However, it is often easy to make special purpose fitting/ prediction
% functions that don't rely on generic optimizers,
% as we did with linregFitSimple.m above.
% In addition,  many of the generative models in pmtk
% should be octave compatible as is, and hence should work fine with mlcomp,
% although we have not done extensive testing...
