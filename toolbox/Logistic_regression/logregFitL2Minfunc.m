function w = logregFitL2Minfunc(objective, winit, lambda, opts, X, y)
% Fit an L2 penalized logistic regression model using minfunc
penobjective = @(w)penalizedL2(w, objective, lambda, X, y);
w = minFunc(penobjective, winit(:), opts);
end