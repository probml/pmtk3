function [model, loglikHist] = probitRegFit(X, y, varargin)
%% Find MAP estimate (under L2 prior) for binary probit regression using EM
%
%% Inputs
% X(i, :) is i'th case
% y(i) is in {-1, +1}
% 
%% Optional named inputs
%
% 'lambda' -  value of the L2 regularizer
% 'preproc' - a preprocessor struct
% 'method' - one of 'em' or 'minfunc'
% 'fitOpts' - cell array passed to emAlgo or minfunc
%
%% Outputs
%
% model is a struct with fields, w, lambda
% loglikHist is the history of the log likelihood

% This file is from pmtk3.googlecode.com

[lambda, method, preproc, fitOpts] = process_options(varargin, ...
  'lambda', 1e-5, ...
  'method', 'minfunc', ...
  'preproc', preprocessorCreate('addOnes', true), ...
  'fitOpts', {});

[model.preproc, X] = preprocessorApplyToTrain(preproc, X);
[N,D] = size(X); %#ok
model.lambda = lambda;
lambdaVec = lambda*ones(D,1);
if preproc.addOnes
    lambdaVec(1, :) = 0; % don't penalize bias term
end
[ypm1, model.ySupport] = setSupport(y, [-1 +1]);

switch lower(method)
  case 'minfunc'
     [model.w, loglikHist] = probitRegFitMinfunc(X, ypm1, lambdaVec, fitOpts{:});
  case 'em'
    [model.w, loglikHist] = probitRegFitEm(X, ypm1, lambdaVec, fitOpts{:});
  otherwise
    error(['unrecognized method ' method])
end

end
