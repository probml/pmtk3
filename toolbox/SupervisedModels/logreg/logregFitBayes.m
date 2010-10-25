function [model, logev, postSummary] = logregFitBayes(X, y, varargin)
% Fit logistic regression using Bayesian inference
% X is n*d, y is d*1, can be 0/1 or -1/+1 or 1..C
% Do not add a column of 1s
%
% By default we use a N(0,(1/lambda) I) prior
%
% INPUTS:
% method: one of these
% - 'laplace' use Laplace approximation: must specify 'lambda' (binary only)
% - 'vb' use Variational Bayes (binary only)
% - 'eb' use Empirical Bayes (can be multiclass, uses netlab)
%
% preproc       ... a struct, passed to preprocessorApplyToTtrain
%
% OUTPUT
% model.wN and model.VN contain posterior.
% logev is  the log marginal likelihood

% This file is from pmtk3.googlecode.com



[preproc, method, lambda, useARD, displaySummary] = process_options(varargin, ...
  'preproc', preprocessorCreate('addOnes', true, 'standardizeX', true), ...
  'method', 'laplace', 'lambda', 0, 'useARD', false, 'displaySummary', false);

nclasses = nunique(y);
isbinary = nclasses < 3;
if isbinary
  [y, ySupport] = setSupport(y, [-1 1]);
else
  [y, ySupport] = setSupport(y, 1:nclasses);
  if ~strcmpi(method, 'eb')
    error(sprintf('use eb not %s for binary labels', method));
  end
end


switch method
  case 'laplace'
    [model] = logregFitLaplaceApprox(X, y, lambda, preproc);
  case 'vb'
    [model, logev] = logregFitVb(X, y, preproc, useARD);
  case 'eb'
    [model, logev] = logregFitEbNetlab(X, y, preproc);
  otherwise
    error(['unrecognized method ' method])
end

model.type = 'logregBayes';
model.ySupport = ySupport;
model.binary = isbinary;

if nargout >= 3
  postSummary = logregPostSummary(model, 'displaySummary', displaySummary);
end

end
