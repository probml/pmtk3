function model = logregL1Fit(X, y, lambda, includeOffset)
    if nargin < 4, includeOffset = true; end
    model = logregL1FitMinfunc(X, y, lambda, includeOffset);
end