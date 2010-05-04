function [model, logev] = linregFitBayes(X, y, varargin)
% Bayesian inference for a linear regression model
% The model is p(y|x) = N(y | w0 + w'*x, (1/beta))
% so beta is the precision of the measurement  noise
% We deal with w0 separately, performing point estimation.
% INPUTS:
% prior ... 'uninf' means use Jeffrey's prior on w and beta
%           'vb' means use variational Bayes with vague NGamGam prior 
%           'gauss' means use N(0, (1/alpha) I) prior on w, beta is fixed
% beta ...   precision of measurement noise
% alpha  ... scalar precision of Gaussian
% preproc       ... a struct, passed to preprocessorApplyToTtrain
%
% If the prior is Gaussian, the posterior is
%   p(w|D) = N(w| wN, VN)
% If beta is unknwon, the posterior is
%   p(w, beta | D) = N(w | wN, (1/beta) VN) Ga(beta | aN, bN)
%
% logev is  the log marginal likelihood

[N, D] = size(X);
args = prepareArgs(varargin); % converts struct args to a cell array
[prior, preproc,  beta, alpha] = ...
  process_options(args , ...
  'prior', [], ...
  'preproc', [], ...      
  'beta', [], ...
  'alpha', [] ...
 );


Xraw = X; 
[preproc, X] = preprocessorApplyToTrain(preproc, X);
addOnes = false;
if addOnes
  X = [ones(N,1) X];
else
  [y, ybar] = centerCols(y);
end

switch prior
  case 'uninf', [model, logev] = linregFitBayesJeffreysPrior(X, y, addOnes);
  case 'vb', [model, logev] = linregFitVb(X, y, addOnes);
  case 'gauss', [model, logev] = linregFitBayesGaussPrior(X, y, alpha, beta, addOnes);
end

model.preproc = preproc;
if addOnes
  %model.offset = model.wN(1);
  %model.wN = model.wN(2:end);
  model.addOnes = true;
else
  model.offset = 0;
  model.addOnes = false;
  yhat = linregPredictBayes(model, mean(Xraw));
  model.offset  = ybar - yhat;
end

end % end of main function

