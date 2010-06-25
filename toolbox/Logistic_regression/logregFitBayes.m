function [model, logev] = logregFitBayes(X, y, varargin)
% Fit *binary* logistic regression using Bayesian inference
% X is n*d, y is d*1, can be 0/1 or -1/+1
% Do not add a column of 1s
%
% By default we use a N(0,(1/lambda) I) prior
%
% INPUTS:
% method: one of these
% - 'laplace' use Laplace approximation: must specify lambda
% - 'vb' use Variational Bayes
% - 'eb' use Empircal Bayes
%
% preproc       ... a struct, passed to preprocessorApplyToTtrain
%
% OUTPUT
% model.wN and model.VN contain posterior.
% logev is  the log marginal likelihood

wantLogev = (nargout >= 2);
if wantLogev
  method = 'vb';
else
  method = 'laplace'; % faster
end

[preproc, method] = process_options(varargin, ...
  'preproc', preprocessorCreate('addOnes', true, 'standardizeX', false), ...
  'method', method);

[model.preproc, X] = preprocessorApplyToTrain(preproc, X);

D = size(X,2);
lambdaVec = lambda*ones(D, 1);
if model.preproc.addOnes
  lambdaVec(1) = 0; % Don't penalize bias term
end

switch method
  case 'laplace'
    [model] = logregFitBayesLaplace(X, y, lambdaVec);
  case 'vb'
    [model, logev] = logregFitVb(X, y);
  case 'eb'
    error('not yet implemented')
    %[model, logev] = logregFitEb(X, y);
  otherwise
    error(['unrecognized method ' method])
end

end
