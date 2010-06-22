function [model, logev] = linregFitBayes(X, y, varargin)
% Bayesian inference for a linear regression model
% The model is p(y|x) = N(y | w'*[1 x], (1/beta))
% so beta is the precision of the measurement  noise
%
% INPUTS:
% prior: one of the4se
% 'uninf' means use Jeffrey's prior on w and beta
% 'vb' means use Variational Bayes with vague NGamGam prior 
% 'eb' means use Empirical Bayes (evidence procedure)
%     Set ebMethod to 'Chen' or 'netlab'
%  'gauss' means use N(0, (1/alpha) I) prior on w
%    Must specify alpha and beta
%  'zellner' means use N(0, 1/g*inv(X'*X)) Ga(sigma|0,0)
%      Must specify g
% preproc       ... a struct, passed to preprocessorApplyToTtrain
%
% If the prior is Gaussian, the posterior is
%   p(w|D) = N(w| wN, VN)
% If beta is unknwon, the posterior is
%   p(w, beta | D) = N(w | wN, (1/beta) VN) Ga(beta | aN, bN)
%
% logev is  the log marginal likelihood


[prior, preproc,  beta, alpha, g, ebMethod] = ...
  process_options(varargin , ...
  'prior', 'uninf', ...
  'preproc', preprocessorCreate('addOnes', true, 'standardizeX', false), ...      
  'beta', [], ...
  'alpha', [], ...
  'g', [], ...
  'ebMethod', 'netlab');

[preproc, X] = preprocessorApplyToTrain(preproc, X);

% if we added 1s to the first column, we should adjust the regularziers
addOnes = preproc.addOnes; 


switch lower(prior)
  case 'uninf', [model, logev] = linregFitBayesJeffreysPrior(X, y, addOnes);
  case 'vb', [model, logev] = linregFitVb(X, y, addOnes);
  case 'gauss', [model, logev] = linregFitBayesGaussPrior(X, y, alpha, beta, addOnes);
  case 'zellner', [model, logev] = linregFitBayesZellnerPrior(X, y, g, addOnes);
  case 'eb',
    switch lower(ebMethod)
      % Both methods erroneously regularize the offset term...
      case 'chen', [model, logev] = linregFitEbChen(X, y);
      case 'netlab', [model, logev] = linregFitEbNetlab(X, y);
    end
end


model.preproc = preproc;
model.modelType = 'linregBayes';

end % end of main function

