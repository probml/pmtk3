function [model, allW] = linregL1FitLarsSingleLambda(X, y, lambda, includeOffset) 
% Fit an L1 penalized linear regression model using the lars algorithm, 
% (with the 'lasso' modification) to compute the full regularization path, 
% and then linear interpolation to find the weights corresponding to the
% single requested lambda value. 
%
% The includeOffset term is ignored but left for consistency with the
% other linregL1Fit functions since it is not supported by lars. 
%
% This wrapper function centers y, as required by lars. 
     
     [y, model.ymu] = center(y);
     allW = lars(X, y, 'lasso');
     w = colvec(interpolateLarsWeights(allW, lambda, X, y));
     model.w = w;
     model.includeOffset = false;
     model.sigma2 = var((X*w - y).^2); % MLE
end