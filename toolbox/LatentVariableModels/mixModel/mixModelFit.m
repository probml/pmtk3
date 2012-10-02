function [model, loglikHist] = mixModelFit(data, nmix, type, varargin)
%% Fit a mixture model via MLE/MAP (using EM)
%
% By default we lightly regularize the parameters, so we are doing map
% estimation. To turn this off, set 'prior' and 'mixPrior to 'none'. See
% Inputs below.
%
%% Inputs
%
% data     - data(i, :) is the ith case, i.e. data is of size n-by-d
% nmix     - the number of mixture components to use
% type     - a string, either 'gauss', 'student', or 'discrete'
%            note that 'discrete' means a product of discrete distributions,
%            hence data can (optionally) be vector valued.
%
%% Optional named Inputs
%
% initParams  - a optional struct storing parameters to use for
%               initialization for the first run, (i.e. first
%               randomRestart). The fields depend on the type. For 'gauss',
%               set mu (d-by-nmix), Sigma (d-by-d-by-nmix), mixWeight
%               (1-by-nmix). For 'student', add dof (1-by-nmix) in addition
%               to the gauss' fields. For 'discrete', include T
%              (nObsStates-by-nstates-by-d) as well as mixWeight.
%               If not specified, we initialize 'gauss', and 'student'
%               using kmeans, and 'discrete' by fitting each component on
%               random subsets of the data.
%
% prior      - a struct with type-dependent fields. For 'guass', this is a
%              gaussInvWishart distribution, hence the fields are 'mu', 'Sigma',
%              'dof', 'k'. We don't currently support a prior for
%              'student'. For 'discrete', use 'alpha', the pseudo
%              counts. Alpha must be either a scalar or of size
%              nObsStates-by-nstates-by-d. An alpha value of 1 effectively
%              means no prior since the map estimate adds alpha-1.
%
%              By default, we lightly regularize the parameters, set prior
%              to 'none' to do mle.
%
% mixPrior   - these are pseudoCounts for the mixture distribution. This
%              must be a scalar or of size 1-by-nmix. Set to 'none' to do
%              MLE. A value of 1 effectively means no prior, since the map
%              estimate adds mixPrior -1.
%
% overRelaxFactor - Currently only supported for 'gauss'. If set,
%                   over-relaxed EM is run. See emAlgoAdaptiveOverRelaxed
%                   for details.
%
% See emAlgo for additional EM related inputs
%% Outputs
% 
% A structure - see mixModelCreate for field descriptions
% loglikHist  - a record of the log likelihood at each EM iteration. 
%% 

% This file is from pmtk3.googlecode.com

[model, loglikHist] = mixModelFitEm(data, nmix, type, varargin{:});
end
Hide details
Change log
r2550 by mattbdunham on Sep 8, 2010   Diff
added copyright text to every file using
insertCopyrightPmtk.m
Go to: 	
Older revisions
 r2384 by mattbdunham on Aug 30, 2010   Diff 
 r2372 by mattbdunham on Aug 28, 2010   Diff 
 r2350 by mattbdunham on Aug 27, 2010   Diff 
All revisions of this file
File info
Size: 2670 bytes, 59 lines
View raw file
