function [model, loglikHist] = hmmFit(data, nstates, type, varargin)
%% Fit a hidden markov model (by default, we use  EM)
%
%% Inputs
% data         - data{i} is a d*seqLength(i) matrix of observations,
%                 where d = size of observation (d=1 if type = 'discrete')
%
% nstates      - the number of hidden states
%
% type         - a string, either 'gauss', 'mixGaussTied', 'discrete', or
%                'student', depending on the desired emission i.e observation
%                (local) distribution.
%
%                See condMixGaussTiedCpdCreate for more details on the
%                'mixGaussTied' option. 
%
%                Note, if type is student, we do not estimate the dof. If
%                you specify emission0, we use this value, otherwise we
%                estimate it once ignoring temporal structure.
%
%
% By default, we lightly regularize all parameters, so we are 
% doing MAP estimation, not MLE. You can change the priors 
% by modifying the named arguments below.
%
%% Optional named arguments
%
% pi0           - specify an initial value for the starting distribution
%                 instead of randomly initiializing. This is an
%                 1-by-nstates vector that sums to one. 
%
% trans0        - specify an initial value for the transition matrix
%                 instead of randomly initializing. This is an
%                 nstates-by-nstates matrix whos *rows* sum to one. 
%
% emission0     - specify an initial value for the emission (local) 
%                 distribution instead of randomly initializing. If type is
%                 'discrete', this is a tabularCpd, if type is 'gauss',
%                 this is a condGaussCpd, as created by tabularCpdCreate or
%                 condGaussCpdCreate. 
%
% piPrior       - pseudo counts for the starting distribution
%                 This is alpha(k)+1 in the Dirichlet
%                 so piPrior = 0 corresponds to MLE
%
% transPrior    - pseudo counts for the transition matrix, (either
%                 nstates-by-nstates or 1-by-nstates in which case it is
%                 automatically replicated.
%
% emissionPrior - If type is 'discrete', this is a struct with field 'alpha'
%                 an nstates-by-nObsStates matrix of pseudoCounts. If type
%                 is 'gauss', or 'mixGaussTied', emissionPrior is a struct 
%                 with the parameters of a Gauss-inverseWishart 
%                 distribution, namely, mu, Sigma, dof, k. We don't
%                 currently support an emission prior for type 'student'.
%
%% EM related inputs
% *** See emAlgo for additional EM related optional inputs ***
%
%% Outputs
%
% model         - a struct with fields, pi, A, emission, nstates, type
% loglikHist(t)    -  observed data log likelihood at iteration t
%
%%

% This file is from pmtk3.googlecode.com

[model, loglikHist] = hmmFitEm(data, nstates, type, varargin{:});
end
