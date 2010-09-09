function [model, logev, postSummary] = linregFitBayes(X, y, varargin)
% Bayesian inference for a linear regression model
% The model is p(y|x) = N(y | w'*[1 x], (1/beta))
% so beta is the precision of the measurement  noise
%
% INPUTS:
% prior: one of these
%- 'uninf' means use Jeffrey's prior on w and beta
%- 'vb' means use Variational Bayes with vague NGamGam prior 
%- 'eb' means use Empirical Bayes (evidence procedure)
%     Set ebMethod to 'Chen' or 'netlab'
%- 'gauss' means use N(0, (1/alpha) I) prior on w
%    Must specify alpha and beta
%- 'zellner' means use N(0, 1/g*inv(X'*X)) Ga(sigma|0,0)
%      Must specify g
% useArd: set to true to use N(0, inv(diag(alpha)) prior
%   for automatic relevancy determination 
% preproc       ... a struct, passed to preprocessorApplyToTtrain
% displaySummary ... set to true to display summary of posterior
%
% If the prior is Gaussian, the posterior is
%   p(w|D) = N(w| wN, VN)
% If beta is unknwon, the posterior is
%   p(w, beta | D) = N(w | wN, (1/beta) VN) Ga(beta | aN, bN)
%
% OUTPUTS
% model contains the parameters of the posterior,
% suitable for input to linregPredictBayes
%
% logev is  the log marginal likelihood
%
% postSummary is a summary of the posterior;
% see linregPostSummary for details

% This file is from pmtk3.googlecode.com


[prior, preproc,  beta, alpha, g, useARD, displaySummary] = ...
  process_options(varargin , ...
  'prior', 'uninf', ...
  'preproc', preprocessorCreate('addOnes', true, 'standardizeX', false), ...      
  'beta', [], ...
  'alpha', [], ...
  'g', [], ...
  'useARD', false, ...
  'displaySummary', false);

% The prior is p(w) = N(w|0, (1/alpha) I)
% which shrinks the offset term w(1) as well.
% If we added 1s to the first column, we should adjust alpha.
% Currently the EB and VB code cannot handle this
% The VB ARD code could be modified to do so, but this has not been done 

if strcmpi(prior, 'eb')
  prior = 'ebnetlab';
end

switch lower(prior)
  case 'uninf', [model, logev] = linregFitBayesJeffreysPrior(X, y, preproc);
  case 'gauss', [model, logev] = linregFitBayesGaussPrior(X, y, alpha, beta, preproc);
  case 'zellner', [model, logev] = linregFitBayesZellnerPrior(X, y, g, preproc);
  case 'vb', [model, logev] = linregFitVb(X, y, preproc, useARD);
  case 'ebnetlab', [model, logev] = linregFitEbNetlab(X, y, preproc);
  case 'ebchen', [model, logev] = linregFitEbChen(X, y, preproc);
end

model.modelType = 'linregBayes';
model.prior = prior;

postSummary = [];
if nargout >= 3 && ~strcmpi(prior, 'ebnetlab')
    postSummary = linregPostSummary(model, 'displaySummary', displaySummary);
end

end % end of main function

