function model = logregFitL2(X, y, lambda, includeOffset)
    
    if nargin < 3, lambda        = 0;    end
    if nargin < 4, includeOffset = true; end
    
    model = logregFitCore(X, y, lambda, includeOffset, @penalizedL2);
end