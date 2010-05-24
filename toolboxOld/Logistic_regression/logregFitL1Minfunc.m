function w = logregFitL1Minfunc(objective, winit, lambda, opts, X, y)
% Fit an L1 penalized logistic regression model using minfunc
penobjective = @(w)penalizedL1(w, objective, lambda, X, y);
w = minFunc(penobjective, winit(:), opts);
end