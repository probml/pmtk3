function model = logregFigL1(X, y, lambda, includeOffset)
    if nargin < 4, includeOffset = true; end
    model = logregFitCore(X, y, lambda, includeOffset, @penalizedL1);
end