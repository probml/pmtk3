function [w, allW] = linregFitL1LarsSingleLambda(X, y, lambda) 
% Fit an L1 penalized linear regression model using the lars algorithm, 
% (with the 'lasso' modification) to compute the full regularization path, 
% and then linear interpolation to find the weights corresponding to the
% single requested lambda value. 
% (Of course, it is inefficient to repeatedly rerun lars...)

allW = lars(X, y, 'lasso');
w = colvec(interpolateLarsWeights(allW, lambda, X, y));

end