function model = linregL1Fit(X, y, lambda, includeOffset)
% Default fitting function for L1 Linear Regression     
    model = linregL1FitShooting(X, y, lambda, includeOffset);
end