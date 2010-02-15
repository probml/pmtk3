function w = linregFitL2Minfunc(X, y, lambda)
% Ridge regression using Newton's method


D = size(X,2);
winit = zeros(D,1);
if isscalar(lambda)
  lambda = lambda*ones(D,1);
end
funObj = @(w)LinregLoss(w,X,y);
options.Display = 'none';
w = minFunc(@penalizedL2, winit, options, funObj, lambda);


