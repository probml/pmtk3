function [w, loglikHist] = probitRegFitMinfunc(X, ypm1, lambdaVec, varargin)
%% Find MAP estimate (under L2 prior) for binary probit regression using EM
% y(i) is +1,-1

% This file is from pmtk3.googlecode.com


D = size(X,2);
winit = zeros(D,1);
options.display = 'off';
funObj = @(w)ProbitLoss(w,X,ypm1);
[w, objMinfunc, exitflaf, output] = ...
  minFunc(@penalizedL2, winit,options,funObj,lambdaVec); %#ok
loglikHist = -output.trace.fval;

end
