function w = linregFitL2Minfunc(X, y, lambda, options)
% Ridge regression using Newton's method

% This file is from pmtk3.googlecode.com



D = size(X,2);
winit = zeros(D,1);
if isscalar(lambda)
  lambda = lambda*ones(D,1);
end
funObj = @(w)LinregLoss(w,X,y);
options.Display = 'none';
w = minFunc(@penalizedL2, winit, options, funObj, lambda);


end
